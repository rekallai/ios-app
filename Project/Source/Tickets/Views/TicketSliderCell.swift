//
//  TicketSliderCell.swift
//  Rekall
//
//  Created by Steve on 10/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TicketSliderCell: UICollectionViewCell {

    static let identifier = "TicketSliderCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var imageView: ProxyImageView!
    @IBOutlet weak var qrImageView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}
