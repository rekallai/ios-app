//
//  TextInputCell.swift
//  Rekall
//
//  Created by Ray Hunter on 24/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit


class PaymentTextInputCell: TextInputCell {
        
    enum CellType: CaseIterable {
        case firstName
        case lastName
        case email
        case password
        case cardNumber
        case securityCode
        case month
        case year
        case zipCode
    }
    
    private var previousCreditCardTextFieldContent: String?
    private var previousCreditCardSelection: UITextRange?
    
    var cellType: CellType?
    
    func set(cellType: CellType, textContent: String?, userIsSignedIn: Bool){
        self.cellType = cellType
        textField.text = textContent
        
        switch cellType {
        case .firstName:
            titleLabel.text = NSLocalizedString("First Name", comment: "Text Field Label")
        case .lastName:
            titleLabel.text = NSLocalizedString("Last Name", comment: "Text Field Label")
        case .email:
            titleLabel.text = NSLocalizedString("Email", comment: "Text Field Label")
        case .password:
            titleLabel.text = NSLocalizedString("Create Password", comment: "Text Field Label")
        case .cardNumber:
            titleLabel.text = NSLocalizedString("Card Number", comment: "Text Field Label")
        case .securityCode:
            titleLabel.text = NSLocalizedString("Security Code", comment: "Text Field Label")
        case .month:
            titleLabel.text = NSLocalizedString("Month", comment: "Text Field Label")
        case .year:
            titleLabel.text = NSLocalizedString("Year", comment: "Text Field Label")
        case .zipCode:
            titleLabel.text = NSLocalizedString("Zip Code", comment: "Text Field Label")
        }
        
        switch cellType {
        case .email:
            separatorInset.left = userIsSignedIn ? 10000 : 15
        case .password, .zipCode:
            separatorInset.left = 10000
        case .securityCode:
            separatorInset.left = 0
        default:
            separatorInset.left = 15
        }
        
        switch cellType {
        case .email:
            textField.keyboardType = .emailAddress
        case .firstName, .lastName, .password:
            textField.keyboardType = .default
        default:
            textField.keyboardType = .numbersAndPunctuation
        }
        let isName = (cellType == .firstName || cellType == .lastName)
        textField.autocapitalizationType = isName ? .words : .none
        textField.returnKeyType = cellType == .zipCode ? .done : .next
    }
    
    
    func setEditable(_ editable: Bool) {
        textField.isEnabled = editable
    }
    
    
    @IBAction override func textInputChanged(_ sender: UITextField) {
        guard cellType == cellType else { return }
        
        switch cellType {
        case .cardNumber:
            reformatAsCardNumber(textField: sender)
        case .month:
            if let text = sender.text, let intVal = Int(text) {
                if 2 <= intVal && intVal <= 12 {
                    delegate?.textFieldInputComplete?(sender: self)
                }
            }
        case .year:
            if let text = sender.text, let intVal = Int(text) {
                if intVal >= 2019 || intVal == 19 || (21 <= intVal && intVal <= 99) {
                    delegate?.textFieldInputComplete?(sender: self)
                }
            }
        default:
            break
        }

        super.textInputChanged(sender)
    }
}


extension PaymentTextInputCell {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard cellType == cellType else { return true }
        
        switch cellType {
        case .cardNumber:
            previousCreditCardTextFieldContent = textField.text
            previousCreditCardSelection = textField.selectedTextRange
            return true
        default:
            break
        }
        
        
        return true
    }
    
    

    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }

        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text,
                                                           andPreserveCursorPosition: &targetCursorPosition)
        }

        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousCreditCardTextFieldContent
            textField.selectedTextRange = previousCreditCardSelection
            return
        }

        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces,
                                                               preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces

        if let targetPosition = textField.position(from: textField.beginningOfDocument,
                                                   offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }

    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition

        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return digitsOnlyString
    }

    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns

        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")

        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",

            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
        ].contains { string.hasPrefix($0) }

        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)

        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition

        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)

            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")

                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }

            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }

        return stringWithAddedSpaces
    }
}
