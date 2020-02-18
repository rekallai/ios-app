//
//  FavoriteVenuesViewController.swift
//  Rekall
//
//  Created by Steve on 8/27/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class FavoriteVenuesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var venueViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let userViewModel = UserViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My Favorite Venues", comment: "Title")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryVenueCell.nib, forCellReuseIdentifier: CategoryVenueCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reseting the vm here to reload data and make sure if venue
        //is un-favorited on detail scene it will be removed from list
        loadFavorites()
        tableView.backgroundView = nil
        tableView.reloadData()
    }

    func loadFavorites() {
        venueViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
        venueViewModel.venueIds = userViewModel.user.favoriteVenueIds
    }
    
    func favoriteTapped(indexPath: IndexPath) {
        let venue = venueViewModel.venue(at: indexPath.row)
        userViewModel.updateFavorite(venue?.id ?? "")
        loadFavorites()
        if indexPath.row == 0 && isEmpty() {
            tableView.deleteSections(IndexSet(integer: 0), with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func isEmpty()->Bool {
        return (venueViewModel.numberOfItems == 0)
    }

}

extension FavoriteVenuesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isEmpty() {
            let title = NSLocalizedString("No Favorite Venues", comment: "Title")
            let message = NSLocalizedString("When you have favorite venues, you'll see them here", comment: "Body")
            let icon = UIImage(named: "SignInFavoritesIcon")
            tableView.empty(title: title, message: message, icon: icon)
            return 0
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueViewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let venue = venueViewModel.venue(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryVenueCell.identifier, for: indexPath) as! CategoryVenueCell
        cell.selectionStyle = .none
        cell.venue = venue
        
        return cell
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
            if let vc = UIStoryboard.venueDetail() {
                vc.venue = venue
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
