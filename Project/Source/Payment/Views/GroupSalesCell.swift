//
//  GroupSalesCell.swift
//  Rekall
//
//  Created by Steve on 10/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class GroupSalesCell: UITableViewCell {

    @IBOutlet weak var bodyLabel: UILabel!

    func setLinkColor(text: String) {
        if let attr = bodyLabel.attributedText {
            let mutable = NSMutableAttributedString(attributedString: attr)
            mutable.setTextBlackWhite()
            mutable.set(color: UIColor(named: "LinkColor")!, on: text)
            bodyLabel.attributedText = mutable
        }
    }
    
}
