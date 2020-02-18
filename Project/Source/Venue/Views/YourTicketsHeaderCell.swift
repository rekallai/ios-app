//
//  YourTicketsHeaderCell.swift
//  Rekall
//
//  Created by Steve on 9/9/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class YourTicketsHeaderCell: UITableViewCell {
    static let identifier = "YourTicketsHeaderCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
