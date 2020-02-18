//
//  PurchasedOrdersViewController.swift
//  Rekall
//
//  Created by Steve on 8/27/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PurchasedOrdersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My Tickets", comment: "Title")
        tableView.register(YourTicketsCell.nib, forCellReuseIdentifier: YourTicketsCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.coreDataModelDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    func openVenueDetail(venue:Venue, ticket:PurchasedOrder) {
        if let vc = UIStoryboard.ticketDetail() {
            vc.venue = venue
            vc.order = ticket
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func isEmpty()->Bool {
        return (viewModel.numberOfItems == 0)
    }

}

extension PurchasedOrdersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isEmpty() {
            let title = NSLocalizedString("No Tickets", comment: "Title")
            let message = NSLocalizedString("When you have tickets, you'll see them here", comment: "Title")
            let icon = UIImage(named: "TicketBlue")
            tableView.empty(title: title, message: message, icon: icon)
            return 0
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configYourTicketCell(tv: tableView, ip: indexPath)
    }
    
}

extension PurchasedOrdersViewController {
    
    func configYourTicketCell(tv: UITableView, ip: IndexPath)->YourTicketsCell {
        let ticket = viewModel.purchasedOrder(at: ip.row)
        let cell = tv.dequeueReusableCell(withIdentifier: YourTicketsCell.identifier, for: ip) as! YourTicketsCell
        cell.order = ticket
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
}

extension PurchasedOrdersViewController: YourTicketsCellDelegate {
    
    func tapped(cell: YourTicketsCell) {
        if let ip = tableView.indexPath(for: cell), let ticket = viewModel.purchasedOrder(at: ip.row), let vid = ticket.venueId, let venue = Venue.load(id: vid) {
            openVenueDetail(venue: venue, ticket: ticket)
        } else {
            let error = NSLocalizedString("Sorry, we couldn't load your data", comment: "Error")
            showError(error: error)
        }
    }
    
}

extension PurchasedOrdersViewController: CoreDataViewModelDelegate {
    
    func didProcessModelUpdates(sender: CoreDataViewModel) {
        tableView.reloadData()
    }
    
}
