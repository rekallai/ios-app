//
//  PaymentVenueTitleCell.swift
//  Rekall
//
//  Created by Ray Hunter on 25/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PaymentVenueTitleCell: UITableViewCell {

    @IBOutlet var venueImageView: ProxyImageView!
    @IBOutlet var venueImageOverlayView: UIView!
    @IBOutlet var venueTitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        venueImageView.layer.cornerRadius = 8.0
        venueImageOverlayView.layer.cornerRadius = 8.0
    }
    
    var venue: Venue? {
        didSet {
            venueImageView.image = nil
            if let url = venue?.imageUrls?.first {
                venueImageView.setProxyImage(url: url)
            }
            
            venueTitleLabel.text = venue?.name
            
            // ToDo
            dateLabel.text = "All day access pass"
        }
    }
    
}
