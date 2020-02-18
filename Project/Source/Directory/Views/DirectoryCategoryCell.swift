//
//  DirectoryCategoryCell.swift
//  Rekall
//
//  Created by Steve on 7/31/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class DirectoryCategoryCell: UICollectionViewCell {
    static let identifier = "DirectoryCategoryCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var category: Category? {
        didSet {
            if let category = category {
                titleLabel?.text = category.name
                if let img = category.icon() {
                    iconImageView.image = img
                    colorIcon()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = UIColor(named: "DirectoryCell")
        iconImageView.image = UIImage(named: "Directory/Books&Cards")
        colorIcon()
    }
    
    private func colorIcon() {
        iconImageView.setColor(UIColor(named: "BlackWhite")!)
    }
    
}
