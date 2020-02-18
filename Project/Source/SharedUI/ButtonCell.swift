//
//  ButtonCell.swift
//  Rekall
//
//  Created by Steve on 10/7/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate: class {
    func buttonCellTapped(cell: ButtonCell)
}

class ButtonCell: UITableViewCell {
    weak var delegate: ButtonCellDelegate?
    
    static let identifier = "ButtonCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var button: FillButton!
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.buttonCellTapped(cell: self)
    }
    
}
