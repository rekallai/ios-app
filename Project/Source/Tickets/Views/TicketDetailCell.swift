//
//  TicketDetailCell.swift
//  Rekall
//
//  Created by Steve on 9/17/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TicketDetailCell: UITableViewCell {

    static let identifier = "TicketDetailCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
