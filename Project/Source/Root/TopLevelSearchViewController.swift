//
//  TopLevelSearchViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 20/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

//
//  UIViewController subclass that is the base for each tabs root view controller
//
class TopLevelSearchViewController: UIViewController {

    var resultsController: SearchResultsController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let sb = UIStoryboard(name: "Main", bundle: nil)
        resultsController = sb.instantiateViewController(withIdentifier: "SearchResultsController") as? SearchResultsController
        resultsController?.delegate = self
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension TopLevelSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        resultsController?.searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces)
    }
}

extension TopLevelSearchViewController: SearchResultsControllerDelegate {
    func searchResultsController(controller: SearchResultsController, didSelect item: DataItem) {
        if let venue = item as? Venue {
            guard let vc = UIStoryboard.venueDetail() else { return }
            vc.venue = venue
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if let event = item as? Event {
            guard let vc = UIStoryboard.eventDetail() else { return }
            vc.event = event
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
