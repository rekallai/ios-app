//
//  TermsPrivacyCell.swift
//  Rekall
//
//  Created by Steve on 10/22/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TermsPrivacyCell: UITableViewCell {

    static let identifier = "TermsAndPrivacy"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var acceptSwitch: UISwitch!
    
    func setLinkColor() {
        let linkTexts = ["Terms of Service", "Privacy Policy"]
        if let label = viewWithTag(10) as? UILabel, let attr = label.attributedText {
            let mutable = NSMutableAttributedString(attributedString: attr)
            mutable.setTextBlackWhite()
            linkTexts.forEach { (txt) in
                let linkColor = UIColor(named: "LinkColor")!
                mutable.set(color: linkColor, on: txt)
            }
            label.attributedText = mutable
        }
    }
    
}
