//
//  WhatsNearbyViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 03/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@available(iOS 13, *)
protocol WhatsNearbyDelegate: class {
    func whatsNearbyDidSelectSection(section: WhatsNearbyViewController.Section)
}

@available(iOS 13, *)
class WhatsNearbyViewController: PersistentDrawerContentViewController {
    
    weak var delegate: WhatsNearbyDelegate?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

@available(iOS 13, *)
extension WhatsNearbyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    enum Section: Int, CaseIterable {
        case restrooms
        case service
        case favorites
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Section.allCases.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: WhatsNewCell.identifier,
                                                       for: indexPath) as! WhatsNewCell
        
        guard let section = Section(rawValue: indexPath.item) else {
            fatalError("WhatsNearbyViewController inhandled section")
        }
        
        switch section {
        case .restrooms:
            cell.textLabel.text = NSLocalizedString("Restrooms", comment: "What's nearby title")
            cell.imageView.image = UIImage(named: "MapsNearbyRestrooms")
        case .service:
            cell.textLabel.text = NSLocalizedString("Information", comment: "What's nearby title")
            cell.imageView.image = UIImage(named: "MapsNearbyConcierge")
        case .favorites:
            cell.textLabel.text = NSLocalizedString("Favorites", comment: "What's nearby title")
            cell.imageView.image = UIImage(named: "MapsNearbyFavorites")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.item) else {
            fatalError("WhatsNearbyViewController inhandled section")
        }

        delegate?.whatsNearbyDidSelectSection(section: section)
    }
}
