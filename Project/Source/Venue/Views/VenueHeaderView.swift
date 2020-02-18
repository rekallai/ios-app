//
//  VenueHeaderView.swift
//  Rekall
//
//  Created by Steve on 7/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol VenueHeaderViewDelegate: class {
    func tappedActionButton()
}

class VenueHeaderView: UITableViewHeaderFooterView {

    static let identifier = "VenueHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: VenueHeaderViewDelegate?
    var imageDataSource = ImageSliderDataSource()
    
    @IBOutlet weak var imageCollectionView: ImageSliderCollectionView?
    @IBOutlet weak var imagePage: UIPageControl?
    @IBOutlet weak var openCloseLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var costLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var actionButton: FillButton?
    @IBOutlet weak var buttonStack: UIStackView!
    
    var venue:Venue? {
        didSet {
            if let venue = venue {
                costLabel?.text = venue.costIndicator
                titleLabel?.text = venue.name
                descriptionLabel?.text = venue.itemDescription
                imageDataSource.imageUrls = venue.imageUrls ?? []
                let imgCount = venue.imageUrls?.count ?? 0
                imagePage?.numberOfPages = imgCount
                imageCollectionView?.isUserInteractionEnabled = (imgCount > 1)
                setIsComingSoon(venue: venue)
                checkActionButton(venue: venue)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageDataSource.delegate = self
        imageCollectionView?.delegate = imageDataSource
        imageCollectionView?.dataSource = imageDataSource
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        delegate?.tappedActionButton()
    }
    
    func setIsComingSoon(venue: Venue) {
        if venue.isComingSoon() {
            openCloseLabel?.text = NSLocalizedString("Coming Soon", comment: "Label Title")
        } else {
            openCloseLabel?.text = venue.openCloseEvent()
        }
    }
    
    func checkActionButton(venue: Venue) {
        if venue.isComingSoon() || !venue.hasTickets {
            actionButton?.removeFromSuperview()
        }
    }
    
}

extension VenueHeaderView: ImageSliderDelegate {
    
    func imageChanged(page: Int) {
        imagePage?.currentPage = page
    }
    
}
