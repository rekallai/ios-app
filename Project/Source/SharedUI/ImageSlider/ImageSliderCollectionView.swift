//
//  ImageSliderCollectionView.swift
//  Rekall
//
//  Created by Steve on 7/26/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ImageSliderCollectionView: UICollectionView {

    override func awakeFromNib() {
        super.awakeFromNib()
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        register(
            ImageSliderCell.nib,
            forCellWithReuseIdentifier: ImageSliderCell.identifier
        )
    }

}
