//
//  AttractionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 06/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

protocol AttractionCellDelegate: class {
    func ticketsButtonTapped(venue: Venue?)
}

class AttractionCell: UITableViewCell {
    
    static let identifier = "AttractionCell"
    @IBOutlet var attractionImageView: RoundedImageView?
    @IBOutlet var hoursLabel: UILabel?
    @IBOutlet var venueNameLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet weak var getTicketsButton: PillButton?
    
    weak var delegate: AttractionCellDelegate?
    
    var venue: Venue? {
        didSet {
            attractionImageView?.image = nil
            if let url = venue?.imageUrls?.first {
                attractionImageView?.setProxyImage(url: url)
            }
            venueNameLabel?.text = venue?.name
            descriptionLabel?.text = venue?.itemDescription
            setTicketsButtonVisible()
            setHoursLabel()
        }
    }
        
    @IBAction func getTicketsTapped(_ sender: Any) {
        delegate?.ticketsButtonTapped(venue: venue)
    }
    
    private func setTicketsButtonVisible() {
        let isComing = venue?.isComingSoon() ?? false
        let hasTickets = venue?.hasTickets ?? false
        let isHidden = (isComing || !hasTickets)
        getTicketsButton?.isHidden = isHidden
        getTicketsButton?.alpha = isHidden ? 0.0 : 1.0
    }
    
    private func setHoursLabel() {
        if venue?.isComingSoon() ?? false {
            hoursLabel?.text = "Coming Soon"
        } else {
            hoursLabel?.text = venue?.openingHours?.getNextOpeningOrClosingEventTime()
        }
    }
}
