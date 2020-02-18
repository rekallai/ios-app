//
//  ImageSliderCell.swift
//  Rekall
//
//  Created by Steve on 7/25/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ImageSliderCell: UICollectionViewCell {

    static let identifier = "ImageSliderCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var imageView: ProxyImageView?

}
