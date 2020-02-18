//
//  DetailLinkCell.swift
//  Rekall
//
//  Created by Steve on 7/22/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DetailLinkCell: UITableViewCell {
    
    static let identifier = "DetailLinkCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var textView: LinkTextView?
    
    var addColor = false
    
    override func awakeFromNib() {
        selectionStyle = .none
        textView?.layoutSubviews()
    }
    
    public func setLink(text: String, addColor:Bool) {
        self.addColor = addColor
        let attrStr = NSMutableAttributedString(string: text)
        addLink(attrStr: attrStr)
        textView?.attributedText = attrStr
    }
    
    private func addLink(attrStr: NSMutableAttributedString) {
        let range = NSRange(
            location: 0, length: attrStr.length
        )
        if addColor {
            attrStr.addAttribute(.link, value:"msg://" , range: range)
        }
        let font = UIFont.systemFont(ofSize: 14.0)
        attrStr.addAttribute(.font, value:font, range:range)
    }
    
    private func accessoryImage()->UIImageView {
        return UIImageView(image: UIImage(named: "ContactIcon"))
    }
    
}
