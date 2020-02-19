//
//  VenueHorizontalCollectionCell.swift
//  Rekall
//
//  Created by Ray Hunter on 13/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

protocol HomeHorizontalCellLargeDelegate: class {
    func ticketsTappedInLargeCell(sender: HomeHorizontalCellLarge)
}

class HomeHorizontalCellLarge: UICollectionViewCell {
    
    static let identifier = "HomeHorizontalCellLarge"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: HomeHorizontalCellLargeDelegate?
    var dataItem: DataItem? {
        didSet {
            titleLabel.text = dataItem?.name
            subtitleLabel.text = dataItem?.itemShortDescription
            timeLabel.text = dataItem?.itemTag
            venueImageView.image = nil
            if let url = dataItem?.imageUrls?.first {
                venueImageView.af_setImage(withURL: url)
            }
        }
    }
    
    @IBOutlet var venueImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var ticketsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        venueImageView.layer.cornerRadius = 8.0
        venueImageView.layer.borderWidth = 1.0
        venueImageView.layer.borderColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ticketsButton.layer.cornerRadius = ticketsButton.bounds.height / 2.0
    }
    
    @IBAction func ticketsButtonTapped(_ sender: UIButton) {
        delegate?.ticketsTappedInLargeCell(sender: self)
    }
}
