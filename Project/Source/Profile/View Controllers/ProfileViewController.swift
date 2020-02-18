//
//  ProfileViewController.swift
//  Rekall
//
//  Created by Steve on 6/17/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum ProfileSections: Int, CaseIterable {
    case main
    case logOut
}

enum ProfileCells: Int, CaseIterable {
    case tickets
    case favorites
    case interests
    case contact
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: ProfileTableView!
    let profileIdentifier = "ProfileCell"
    
    @IBAction func unwindEditDetail(_ unwindSegue: UIStoryboardSegue) {
        let section = ProfileSections.main.rawValue
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        setUpUserViewModel() //onUpdateUserSuccess is overwritten in EditDetails
    }
    
    let userViewModel = UserViewModel.shared
    let purchasedOrderViewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setUpUserViewModel()
        addEditButton()
    }
    
    func setUpUserViewModel() {
        userViewModel.onUpdateUserSuccess = { [weak self] in
            let indexSet = IndexSet(integer: ProfileSections.main.rawValue)
            self?.tableView.reloadSections(indexSet, with: .automatic)
        }
    }
    
    func addEditButton() {
        let button = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItems = [button]
    }
    
    @objc func edit() {
        performSegue(withIdentifier: "EditDetailsSegue", sender: self)
    }
    
    func logOut() {
        userViewModel.signOut()
        navigationController?.popViewController(animated: true)
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = ProfileSections(rawValue: section) else { return 0 }
        return (section == .main) ? ProfileCells.allCases.count : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = ProfileSections(rawValue: indexPath.section) else {
            fatalError("No profile section")
        }
        
        if section == .main {
            return configCell(tv: tableView, ip: indexPath)
        } else {
            return configSignOutCell(tv: tableView, ip: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = ProfileSections(rawValue: indexPath.section) else { return }
        
        if section == .main {
            let item = ProfileCells.allCases[indexPath.row]
            switch item {
            case .favorites:
                performSegue(withIdentifier: "FavoriteVenuesSegue", sender: self)
            case .interests:
                if let vc = UIStoryboard.interests() {
                    navigationController?.pushViewController(vc, animated: true)
                }
            case .tickets:
                performSegue(withIdentifier: "TicketsSegue", sender: self)
            case .contact:
                IntercomManager.shared.launchMessenger()
            }
        } else { logOut() }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let section = ProfileSections(rawValue: section) else { return nil }
        
        if section == .main {
            let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: ProfileHeaderView.identifier
            ) as! ProfileHeaderView
            
            let firstName = userViewModel.user.firstName
            let lastName = userViewModel.user.lastName
            let fullName = "\(firstName) \(lastName)"
            view.nameLabel.text = fullName
            view.imageView.setInitials(name: fullName)
            
            return view
        } else { return nil }
    }
    
}

extension ProfileViewController {
    
    func configCell(tv: UITableView, ip: IndexPath)->UITableViewCell {
        
        guard let row = ProfileCells(rawValue: ip.row) else {
            fatalError("No profile cell")
        }
        
        switch row {
        case .tickets:
            return configTickets(tv: tv, ip: ip)
        case .favorites:
            return configFavorites(tv: tv, ip: ip)
        case .interests:
            return configInterests(tv: tv, ip: ip)
        case .contact:
            return configContact(tv: tv, ip: ip)
        }
    }
    
    func configTickets(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileIdentifier,for: ip)
        let count = purchasedOrderViewModel.numberOfItems
        cell.textLabel?.text = NSLocalizedString("My Tickets", comment: "Title")
        cell.detailTextLabel?.text = count > 0 ? "\(count)" : ""
        cell.accessoryView = nil
        return cell
    }
    
    func configFavorites(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileIdentifier,for: ip)
        let count = userViewModel.user.favoriteVenueIds.count
        cell.textLabel?.text = NSLocalizedString("My Favorite Venues", comment: "Title")
        cell.detailTextLabel?.text = count > 0 ?  "\(count)" : ""
        cell.accessoryView = nil
        return cell
    }
    
    func configInterests(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileIdentifier,for: ip)
        cell.textLabel?.text = NSLocalizedString("Tell Us What You Love", comment: "Title")
        cell.detailTextLabel?.text = ""
        cell.accessoryView = nil
        return cell
    }
    
    func configContact(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileIdentifier, for: ip)
        cell.textLabel?.text = NSLocalizedString("Chat With Us", comment: "Title")
        cell.detailTextLabel?.text = ""
        cell.accessoryView = UIImageView(image: UIImage(named: "ChatIcon"))
        return cell
    }
    
    func configSignOutCell(tv: UITableView, ip: IndexPath)->UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "SignOutCell", for: ip) as! SignOutCell
        cell.delegate = self
        return cell
    }
    
}

extension ProfileViewController: SignOutCellDelegate {
    func versionLabelTapped(sender: SignOutCell) {
        performSegue(withIdentifier: "ShowEnvironmentSegue", sender: self)
    }
    
    
}
