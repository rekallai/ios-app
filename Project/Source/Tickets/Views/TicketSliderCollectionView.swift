//
//  TicketSliderCollectionView.swift
//  Rekall
//
//  Created by Steve on 10/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TicketSliderCollectionView: UICollectionView {

    override func awakeFromNib() {
        super.awakeFromNib()
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        register(TicketSliderCell.nib, forCellWithReuseIdentifier: TicketSliderCell.identifier)
    }

}
