//
//  PaymentPasswordCell.swift
//  Rekall
//
//  Created by Ray Hunter on 25/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PaymentPasswordCell: PaymentTextInputCell {

    @IBAction func showHideButtonTapped(_ sender: UIButton) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        let newTitle = textField.isSecureTextEntry ? "Show" : "Hide"
        sender.setTitle(newTitle, for: .normal)
    }
    
}
