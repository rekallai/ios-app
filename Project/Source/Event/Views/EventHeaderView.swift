//
//  EventHeaderView.swift
//  Rekall
//
//  Created by Steve on 9/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class EventHeaderView: UITableViewHeaderFooterView {

    static let identifier = "EventHeaderView"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var imageDataSource = ImageSliderDataSource()
    
    @IBOutlet weak var imageCollectionView: ImageSliderCollectionView!
    @IBOutlet weak var imagePage: UIPageControl!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var event: Event? {
        didSet {
            if let event = event {
                titleLabel.text = event.name
                timeLabel.text = event.startsEndsTime()
                descriptionLabel.text = event.itemDescription
                categoryLabel.text = categoriesList(event: event)
                let imgCount = event.imageUrls?.count ?? 0
                imagePage.numberOfPages = imgCount
                imageDataSource.imageUrls = event.imageUrls ?? []
                imageCollectionView.isUserInteractionEnabled = (imgCount > 1)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageDataSource.delegate = self
        imageCollectionView.delegate = imageDataSource
        imageCollectionView.dataSource = imageDataSource
    }
    
    func categoriesList(event: Event)->String {
        guard let categories = event.categories else { return "" }
        return categories.joined(separator: ", ")
    }
    
}

extension EventHeaderView: ImageSliderDelegate {
    
    func imageChanged(page: Int) {
        imagePage.currentPage = page
    }
    
}
