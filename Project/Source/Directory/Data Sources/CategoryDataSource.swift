//
//  CategoryDataSource.swift
//  Rekall
//
//  Created by Steve on 8/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol CategoryDataSourceDelegate: class {
    func dataSourceUpdated()
    func didSelect(venue: Venue)
    func venueFavorited(indexPath: IndexPath)
}

class CategoryDataSource: NSObject {
    weak var delegate: CategoryDataSourceDelegate?
    var category: Category? {
        didSet {
            venueViewModel.category = category?.name
        }
    }
    let venueViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let userViewModel = UserViewModel.shared
    
    func favoriteTapped(indexPath: IndexPath) {
        let venue = venueViewModel.venue(at: indexPath.row)
        userViewModel.updateFavorite(venue?.id ?? "")
        delegate?.venueFavorited(indexPath:indexPath)
    }
    
}

extension CategoryDataSource: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueViewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryVenueCell.identifier,
            for: indexPath
        ) as! CategoryVenueCell
        
        cell.venue = venueViewModel.venue(at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CategoryHeaderView.identifier
        ) as! CategoryHeaderView
        
        if let category = category {
            view.imageView.image = category.icon()
            view.imageView.setColor(UIColor(named: "BlackWhite")!)
            view.titleLabel.text = category.name
            let count = venueViewModel.numberOfItems
            if count == 0 {
                view.subTitleLabel.text = NSLocalizedString("Coming Soon", comment: "label")
            } else {
                let suffix = count == 1 ? "" : "s"
                let title = NSLocalizedString("Venue\(suffix)", comment: "label")
                view.subTitleLabel.text = "\(count) \(title)"
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let venue = venueViewModel.venue(at: indexPath.row)
        let isFavorited = userViewModel.isFavorited(venue?.id ?? "")
        let favImg = isFavorited ? "HeartFilledIcon" : "HeartIcon"
        let contextItem = UIContextualAction(style: .normal, title:nil) { (action, view, isSuccess) in
            self.favoriteTapped(indexPath:indexPath)
            isSuccess(true)
        }
        contextItem.image = UIImage(named: favImg)
        contextItem.backgroundColor = UIColor(named:"ButtonBackground")
        
        return UISwipeActionsConfiguration(actions:[contextItem])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let venue = venueViewModel.venue(at: indexPath.row) {
            delegate?.didSelect(venue: venue)
        }
        
    }
    
}
