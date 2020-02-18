//
//  AuthTextInputCell.swift
//  Rekall
//
//  Created by Ray Hunter on 07/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class AuthTextInputCell: TextInputCell {
    
    enum CellType: CaseIterable {
        case firstName
        case lastName
        case email
        case password
    }
    
    var cellType: CellType?
    
    func set(cellType: CellType, textContent: String?){
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
            titleLabel.text = NSLocalizedString("Password", comment: "Text Field Label")
        }
    
        switch cellType {
        case .email:
            textField.keyboardType = .emailAddress
        case .firstName, .lastName:
            textField.keyboardType = .default
        default:
            textField.keyboardType = .default
        }
        let isName = (cellType == .firstName || cellType == .lastName)
        textField.isSecureTextEntry = cellType == .password
        textField.autocapitalizationType = isName ? .words : .none
        textField.returnKeyType = cellType == .password ? .done : .next
    }
}
