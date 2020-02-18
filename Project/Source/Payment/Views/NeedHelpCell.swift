//
//  NeedHelpCell.swift
//  Rekall
//
//  Created by Ray Hunter on 06/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol NeedHelpCellDelegate: class {
    func needHelpChatTappedIn(sender: NeedHelpCell)
    func needHelpCallTappedIn(sender: NeedHelpCell)
}

class NeedHelpCell: UITableViewCell {
    
    static let identifier = "NeedHelpCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: NeedHelpCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func needHelpChatTapped(_ sender: UIButton) {
        delegate?.needHelpChatTappedIn(sender: self)
    }
    
    
    @IBAction func needHelpCallTapped(_ sender: UIButton) {
        delegate?.needHelpCallTappedIn(sender: self)
    }
}
