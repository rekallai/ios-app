//
//  FirstViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    var profileButtonManager:ProfileButtonManager?
    
    let restaurantsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let shopsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let attractionsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    //let newAndNotableViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    enum HomeSections: Int, CaseIterable {
        case attractions
        case shops
        case restaurants
    }
    
    private var showingAllTickets = false
    private let maxTicketsShownWhenCollapsed = 3
    
    private var restaurantsDataFailed = false
    private var shopsDataFailed = false
    private var attractionsDataFailed = false
    private var newAndNotableDataFailed = false
    private var eventDataFailed = false
    
    private var isShowingEvents = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.separatorStyle = .none
        tableView?.register(HomeHorizontalCollectionCellLarge.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellLarge.identifier)
        tableView?.register(HomeHorizontalCollectionCellSmall.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellSmall.identifier)
        setUpViewModels()
    }
    
    func setUpViewModels() {
        restaurantsViewModel.venueType = .restaurant

        shopsViewModel.venueType = .shopping
        
        attractionsViewModel.venueType = .attraction
        attractionsViewModel.sortDescriptors = [NSSortDescriptor(key: "comingSoon", ascending: true),
        NSSortDescriptor(key: "importOrdinal", ascending: true)]
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileButtonManager?.shouldDisplay(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profileButtonManager?.shouldDisplay(false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        profileButtonManager?.moveResize()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = HomeSections(rawValue: indexPath.section) else {
            fatalError("Unsupported Home Section")
        }
        
        switch section {
        case .attractions:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Don't Miss Out", comment: "Section title")
            cell.viewModel = attractionsViewModel
            cell.separatorView.isHidden = false
            cell.layoutStyle = .allBigItems
            return cell
        case .restaurants:
            let cell = smallCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Dining", comment: "Section title")
            cell.viewModel = restaurantsViewModel
            cell.seperatorLine.isHidden = true
            return cell
        case .shops:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Shopping", comment: "Section title")
            cell.viewModel = shopsViewModel
            cell.separatorView.isHidden = false
            cell.layoutStyle = .allBigItems
            return cell
        }
    }
}


extension HomeViewController: HomeHorizontalCollectionDelegate {
    
    func largeCollectionScroller(in tableView: UITableView, for indexPath: IndexPath) -> HomeHorizontalCollectionCellLarge {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellLarge.identifier,
                                                       for: indexPath) as? HomeHorizontalCollectionCellLarge else {
                                                        fatalError("Bad cell type")
        }
        
        cell.delegate = self
        return cell
    }
    
    
    func smallCollectionScroller(in tableView: UITableView, for indexPath: IndexPath) -> HomeHorizontalCollectionCellSmall {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellSmall.identifier,
                                                       for: indexPath) as? HomeHorizontalCollectionCellSmall else {
                                                        fatalError("Bad cell type")
        }
        
        cell.delegate = self
        return cell
    }
    
    func userTapped(dataItem: DataItem, sender: UITableViewCell) {
        if let venue = dataItem as? Venue {
            guard let vc = UIStoryboard.venueDetail() else { return }
            vc.venue = venue
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// Protocol extension implementaion for purchased tickets
extension HomeViewController: TableViewCoreDataItemUpdate {}

