//
//  CategoryVenueCell.swift
//  Rekall
//
//  Created by Steve on 8/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class CategoryVenueCell: UITableViewCell {

    static let identifier = "CategoryVenueCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var venueImageView: RoundedImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    
    var updatable: CDUpdateMonitor<Venue>?
    var venue: Venue? {
        set {
            updatable = nil
            if let venue = newValue {
                updatable = CDUpdateMonitor(cdItem: venue) { [weak self] in
                    self?.updateVenueDetails()
                }
            }

            updateVenueDetails()
        }
        get {
            return updatable?.cdItem
        }
    }
    
    func updateVenueDetails() {
        tagLabel.text = ""
        titleLabel.text = venue?.name
        descriptionLabel.text = venue?.itemDescription
        setTime()
        venueImageView?.image = nil
        if let url = venue?.imageUrls?.first {
            venueImageView?.setProxyImage(url: url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        backgroundColor = UIColor(named: "DarkCell")
    }
    
    func setTime() {
        if let venue = venue {
            if venue.comingSoon {
                subLabel.text = NSLocalizedString("Coming Soon", comment: "label")
            } else {
                subLabel.text = venue.openCloseEvent()
            }
        }
    }
    
}
