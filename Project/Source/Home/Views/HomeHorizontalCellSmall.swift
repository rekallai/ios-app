//
//  VenueHorizontalCollectionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeHorizontalCellSmall: UICollectionViewCell {
    
    static let identifier = "HomeHorizontalCellSmall"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var dataItem: DataItem? {
        didSet {
            titleLabel.text = dataItem?.name
            subtitleLabel.text = dataItem?.itemShortDescription
            setTime()
            headerLabel.text = dataItem?.itemTag
            venueImageView.image = nil
            if let url = dataItem?.imageUrls?.first {
                venueImageView.af_setImage(withURL: url)
            }
        }
    }
    
    @IBOutlet var venueImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var distanceAndTimeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        venueImageView.layer.cornerRadius = 8.0
        venueImageView.layer.borderWidth = 1.0
        venueImageView.layer.borderColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    }
    
    func setTime() {
        if let venue = dataItem as? Venue {
            if venue.isComingSoon() {
                distanceAndTimeLabel.text = NSLocalizedString("Coming Soon", comment: "Title")
            } else {
                distanceAndTimeLabel.text = venue.openingHours?.getNextOpeningOrClosingEventTime()
            }
        }        
    }
}
