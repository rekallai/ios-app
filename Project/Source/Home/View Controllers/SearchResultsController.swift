//
//  SearchResultsController.swift
//  Rekall
//
//  Created by Ray Hunter on 20/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol SearchResultsControllerDelegate: class {
    func searchResultsController(controller: SearchResultsController, didSelect item: DataItem)
}

class SearchResultsController: UIViewController {
    
    weak var delegate: SearchResultsControllerDelegate?
    var searchText: String? {
        didSet {
            if searchText?.count ?? 0 > 0 {
                
                if Defines.eventsEnabled {
                    searchEventViewModel.searchText = searchText
                }
                
                searchVenueViewModel.searchText = searchText
                tableView?.reloadData()
            }
        }
    }

    @IBOutlet var tableView: UITableView?
    
    private let searchVenueViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    private let searchEventViewModel = EventViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    
    private enum SearchSection: Int, CaseIterable {
        case event
        case venue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(SearchHeaderView.nib,
                            forHeaderFooterViewReuseIdentifier: SearchHeaderView.identifier)

        searchEventViewModel.dataSection = SearchSection.event.rawValue
        searchVenueViewModel.dataSection = SearchSection.venue.rawValue
        searchEventViewModel.coreDataModelDelegate = self
        searchVenueViewModel.coreDataModelDelegate = self
    }
    
}


extension SearchResultsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SearchSection(rawValue: section) else { return 0 }
        switch section {
        case .event:
            return searchEventViewModel.numberOfItems
        case .venue:
            return searchVenueViewModel.numberOfItems
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        guard let section = SearchSection(rawValue: indexPath.section) else { return cell }
        switch section {
        case .event:
            let item = searchEventViewModel.item(at: indexPath.row)
            cell.textLabel?.text = item?.name
        case .venue:
            let item = searchVenueViewModel.item(at: indexPath.row)
            cell.textLabel?.text = item?.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !Defines.searchHeadersEnabled {
            return nil
        }
        
        guard let section = SearchSection(rawValue: section) else { return nil }

        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeaderView.identifier) as! SearchHeaderView
        
        switch section {
        case .event:
            cell.headerTitleLabel.text = NSLocalizedString("EVENTS", comment: "Header label")
        case .venue:
            cell.headerTitleLabel.text = NSLocalizedString("VENUES", comment: "Header label")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !Defines.searchHeadersEnabled {
            return 0
        }
        
        guard let section = SearchSection(rawValue: section) else { return 0 }

        switch section {
        case .event:
            return searchEventViewModel.numberOfItems > 0 ? 64 : 0
        case .venue:
            return searchVenueViewModel.numberOfItems > 0 ? 64 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SearchSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .event:
            if let event = searchEventViewModel.event(at: indexPath.row) {
                delegate?.searchResultsController(controller: self, didSelect: event)
            }
        case .venue:
            if let venue = searchVenueViewModel.venue(at: indexPath.row) {
                delegate?.searchResultsController(controller: self, didSelect: venue)
            }
        }
    }
}


extension SearchResultsController: CoreDataViewModelDelegate {
    func didProcessModelUpdates(sender: CoreDataViewModel) {
        tableView?.reloadData()
    }
}
