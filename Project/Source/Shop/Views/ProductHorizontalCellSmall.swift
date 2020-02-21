//
//  ProductHorizontalCollectionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

class ProductHorizontalCellSmall: UICollectionViewCell {
    
    static let identifier = "ProductHorizontalCellSmall"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var dataItem: Product? {
        didSet {
            titleLabel.text = dataItem?.name
            subtitleLabel.text = dataItem?.itemShortDescription
            headerLabel.text = dataItem?.itemTag
            productImageView.image = nil
            if let url = dataItem?.imageUrls?.first {
                productImageView.af_setImage(withURL: url)
            }
        }
    }
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.cornerRadius = 8.0
        productImageView.layer.borderWidth = 1.0
        productImageView.layer.borderColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    }
    
}
