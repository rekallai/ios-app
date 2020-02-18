//
//  SecondViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class AttractionsViewController: TopLevelItemViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    @IBOutlet var tableView: UITableView?
    
    private var dataLoadFailed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .automatic
        
        viewModel.venueType = .attraction
        viewModel.sortDescriptors = [NSSortDescriptor(key: "comingSoon", ascending: true),
                                     NSSortDescriptor(key: "importOrdinal", ascending: true)]
        viewModel.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: AttractionCell.identifier, for: indexPath)
        
        guard let cell = c as? AttractionCell else { return c }
        cell.venue = viewModel.venue(at: indexPath.row)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVenue = viewModel.venue(at: indexPath.row)
        if let vc = UIStoryboard.venueDetail() {
            vc.venue = selectedVenue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension AttractionsViewController: TableViewCoreDataItemUpdate { }

extension AttractionsViewController: AttractionCellDelegate {
    
    func ticketsButtonTapped(venue: Venue?) {
        if let vc = UIStoryboard.ticketForm() {
            vc.venue = venue
            navigationController?.pushViewController(
                vc, animated: true
            )
        }
    }
    
}

