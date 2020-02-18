//
//  TicketDetailViewController.swift
//  Rekall
//
//  Created by Steve on 9/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

class TicketDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: TicketDetailTableView!
    
    var poUpdater: CDUpdateMonitor<PurchasedOrder>?
    var order: PurchasedOrder? {
        set {
            poUpdater = nil
            if let order = newValue {
                poUpdater = CDUpdateMonitor(cdItem: order) { [weak self] in
                    self?.setupData()
                }
            }
        }
        get {
            return poUpdater?.cdItem
        }
    }
    
    var venueUpdater: CDUpdateMonitor<Venue>?
    var venue: Venue? {
        set {
            venueUpdater = nil
            if let venue = newValue {
                venueUpdater = CDUpdateMonitor(cdItem: venue) { [weak self] in
                    self?.setupData()
                }
            }
        }
        get {
            return venueUpdater?.cdItem
        }
    }
    
    let dataSource = TicketDetailDataSource()
    let passViewModel = PassViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Ticket Detail", comment: "Title")
        setupData()
    }
    
    func setupData() {
        dataSource.order = order
        dataSource.venue = venue
        dataSource.delegate = self
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        setUpPassViewModel()
        tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func setUpPassViewModel() {
        passViewModel.onSuccess = { [weak self] passes in
            self?.addPasses(passes)
        }
        passViewModel.onFailure = { [weak self] error in
            self?.showError(error: error)
        }
    }
    
    func addPasses(_ passes: [PKPass]) {
        guard let vc = PKAddPassesViewController(passes: passes) else {
            let error = NSLocalizedString("Unable to create pass", comment: "Error")
            self.showError(error: error)
            return
        }
        present(vc, animated: true, completion: nil)
    }
    
    func openMap() {
        if #available(iOS 13.0, *) {
            let sb = UIStoryboard(name: "OnSiteMap", bundle: nil)
            guard let vc = sb.instantiateInitialViewController() as? OnSiteMapViewController else { return }
            vc.destinationVenue = venue
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showiOS13Required()
        }
    }

}

extension TicketDetailViewController: TicketDetailDelegate {
    
    func tappedPassButton() {
        guard let tickets = order?.tickets else { return }
        var idsAndAuthCodes = [(String, String)]()
        
        for ticket in tickets {
            idsAndAuthCodes.append((ticket.id, ticket.passkitAuthorizationToken))
        }
        
        passViewModel.loadPasses(idsAndAuthCodes: idsAndAuthCodes)
    }
    
    func tapped(cell: UITableViewCell) {
        if let index = tableView.indexPath(for: cell), let section = TicketDetailSections(rawValue: index.section) {
            
            switch section {
            case .location:
                openMap()
            case .phone:
                if let phone = venue?.contactDetails?.phoneNo {
                    UIApplication.call(phone: phone)
                }
            case .hours:
                tableView.reloadRows(at: [index], with: .automatic)
            default:
                break
            }
        }
    }
    
    func ticketChanged() {
        let section = TicketDetailSections.orderNumber
        let ip = IndexPath(row: 0, section: section.rawValue)
        tableView.reloadRows(at: [ip], with: .automatic)
    }
    
}
