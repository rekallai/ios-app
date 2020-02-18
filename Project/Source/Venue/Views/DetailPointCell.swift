//
//  DetailPointCell.swift
//  Rekall
//
//  Created by Steve on 6/20/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DetailPointCell: UITableViewCell {
    
    static let identifier = "DetailPointCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    @IBOutlet weak var stack: UIStackView?
    
    func addLabels(_ items:[String], title:String) {
        (title != "") ? addTitle(title) : nil
        items.forEach { (item) in
            let newLabel = UILabel.create(item, isSemi: false)
            stack?.addArrangedSubview(newLabel)
        }
    }
    
    internal override func prepareForReuse() {
        clearLabels()
    }
    
    override func awakeFromNib() {
        selectionStyle = .none
        backgroundColor = UIColor(named: "WhiteBlack")!
    }
    
    private func clearLabels() {
        stack?.arrangedSubviews.forEach({ (view) in
            view.removeFromSuperview()
        })
    }
    
    private func addTitle(_ text:String) {
        let label = UILabel.create(text, isSemi: true)
        stack?.addArrangedSubview(label)
    }
    
}
