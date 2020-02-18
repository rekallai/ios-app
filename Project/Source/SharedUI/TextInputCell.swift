//
//  TextInputCell.swift
//  Rekall
//
//  Created by Ray Hunter on 07/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@objc protocol TextInputCellDelegate: class {
    func textFieldReturnTappedIn(sender: TextInputCell)
    func textFieldContentChangedTo(text: String?, sender: TextInputCell)
    @objc optional func textFieldInputComplete(sender: TextInputCell)
}


class TextInputCell: UITableViewCell {

    weak var delegate: TextInputCellDelegate?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!

    @IBAction func textInputChanged(_ sender: UITextField) {
        delegate?.textFieldContentChangedTo(text: sender.text, sender: self)
    }
}


extension TextInputCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldReturnTappedIn(sender: self)
        return true
    }
}
