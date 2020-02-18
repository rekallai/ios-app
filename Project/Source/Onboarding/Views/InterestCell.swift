//
//  InterestCell.swift
//  Rekall
//
//  Created by Steve on 10/4/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class InterestCell: UICollectionViewCell {
    static let identifier = "InterestCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var squareView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heartImageView.image = UIImage(named:"HeartIcon")
        squareView.layer.cornerRadius = 8
        squareView.layer.masksToBounds = true
        squareView.backgroundColor = .gray
    }
    
    func setIsLiked(_ isLiked:Bool) {
        let imgName = isLiked ? "HeartFilledIcon" : "HeartIcon"
        let squarColor = isLiked ? UIColor(named: "ButtonBackground") : .gray
        heartImageView.image = UIImage(named: imgName)
        squareView.backgroundColor = squarColor
    }
    
}
