//
//  FirstViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class HomeViewController: TopLevelItemViewController {
    
    @IBOutlet var tableView: UITableView?
    var profileButtonManager:ProfileButtonManager?
    
    let purchasedOrdersViewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let eventViewModel = EventViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let restaurantsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let shopsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let attractionsViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    //let newAndNotableViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    enum HomeSections: Int, CaseIterable {
        case ticketsHeader
        case tickets
        case attractions
        case events
        case shops
        case restaurants
        case personalize
        //case newAndNotable
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
        checkOnboarding()
        setUpProfileButton()
        tableView?.separatorStyle = .none
        tableView?.register(HomeHorizontalCollectionCellLarge.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellLarge.identifier)
        tableView?.register(HomeHorizontalCollectionCellSmall.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellSmall.identifier)
        tableView?.register(YourTicketsCell.nib,
                            forCellReuseIdentifier: YourTicketsCell.identifier)
        setUpViewModels()
        updateShowingEvents()
        loadAllData(onlyIfPreviouslyFailed: false)
    }
    
    func setUpViewModels() {
        purchasedOrdersViewModel.dataSection = HomeSections.tickets.rawValue
        purchasedOrdersViewModel.coreDataModelDelegate = self
        purchasedOrdersViewModel.setFuturePredicate()
        
        restaurantsViewModel.venueType = .restaurant

        shopsViewModel.venueType = .shopping
        
        attractionsViewModel.venueType = .attraction
        attractionsViewModel.sortDescriptors = [NSSortDescriptor(key: "comingSoon", ascending: true),
        NSSortDescriptor(key: "importOrdinal", ascending: true)]
        
        eventViewModel.coreDataModelDelegate = self
    }
    
    func loadAllData(onlyIfPreviouslyFailed: Bool) {
        guard onlyIfPreviouslyFailed else {
            purchasedOrdersViewModel.reloadTicketsFromBackend()
            return
        }
    }
    
    func setUpProfileButton() {
        guard let navBar = navigationController?.navigationBar else { return }
        profileButtonManager = ProfileButtonManager(navBar: navBar)
        profileButtonManager?.delegate = self
    }
    
    func checkOnboarding() {
        if !Defaults.hasOnboarded() {
            if let vc = UIStoryboard.onboarding() {
                present(vc, animated: true) {
                    Defaults.setOnboarded()
                }
            }
        }
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
    
    func updateShowingEvents() {
        let shouldShowEvents = Defines.eventsEnabled && eventViewModel.numberOfItems > 0
        guard shouldShowEvents != isShowingEvents else {
            return
        }
        
        isShowingEvents = shouldShowEvents
        
        let sectionsToChange = IndexSet(integersIn: Range<IndexSet.Element>(NSRange(location: HomeSections.events.rawValue,
                                                                                    length: 1))!)
        tableView?.reloadSections(sectionsToChange, with: .automatic)
    }
    
    @IBAction func personalizeButtonTapped(_ sender: UIButton) {
        if let vc = UIStoryboard.interests() {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func ticketsHeaderTapped(_ sender: UITapGestureRecognizer) {
        guard purchasedOrdersViewModel.numberOfItems > maxTicketsShownWhenCollapsed else {
            return
        }
        
        showingAllTickets = !showingAllTickets
        
        var changingIps = [IndexPath]()
        for i in maxTicketsShownWhenCollapsed..<purchasedOrdersViewModel.numberOfItems {
            changingIps.append(IndexPath(row: i, section: HomeSections.tickets.rawValue))
        }
        
        if showingAllTickets {
            tableView?.insertRows(at: changingIps, with: .automatic)
        } else {
            tableView?.deleteRows(at: changingIps, with: .automatic)
        }
        
        let headerIp = IndexPath(row: 0, section: HomeSections.ticketsHeader.rawValue)
        if let headerCell = tableView?.cellForRow(at: headerIp) as? TicketsHeaderCell {
            headerCell.seeAllLabel.text = ticketsHeaderCellText()
        }
    }
    
    private func ticketsHeaderCellText() -> String {
        if purchasedOrdersViewModel.numberOfItems <= maxTicketsShownWhenCollapsed {
            return ""
        }
        
        return showingAllTickets ?
               NSLocalizedString("See Less", comment: "Action Title")  :
               NSLocalizedString("See More(\(purchasedOrdersViewModel.numberOfItems))", comment: "Action Title")
    }
}

extension HomeViewController: ProfileButtonDelegate {
    
    func profileButtonTapped() {
        if ADApi.shared.store.isLoggedIn {
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            if let vc = sb.instantiateInitialViewController() as? ProfileViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = UIStoryboard.preAuth(), let preAuthVC = vc.viewControllers.first as? PreAuthViewController {
                preAuthVC.signUpFlow = false
                present(vc, animated: true, completion:nil)
            }
        }
    }
    
}


extension HomeViewController: YourTicketsCellDelegate {
    
    func tapped(cell: YourTicketsCell) {
        if let ip = tableView?.indexPath(for: cell) {
            let ticket = purchasedOrdersViewModel.purchasedOrder(at: ip.row)
            if let vc = UIStoryboard.ticketDetail(), let vid = ticket?.venueId, let venue = Venue.load(id: vid) {
                vc.venue = venue
                vc.order = ticket
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = HomeSections(rawValue: section) else {
            fatalError("Unsupported Home Section")
        }

        switch section {
        case .ticketsHeader:
            return (purchasedOrdersViewModel.numberOfItems > 0) ? 1 : 0
        case .tickets:
            if showingAllTickets {
                return purchasedOrdersViewModel.numberOfItems
            } else {
                return min(maxTicketsShownWhenCollapsed, purchasedOrdersViewModel.numberOfItems)
            }
        case .events:
            return isShowingEvents ? 1 : 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = HomeSections(rawValue: indexPath.section) else {
            fatalError("Unsupported Home Section")
        }
        
        switch section {
        case .ticketsHeader:
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "TicketsHeader",
                                                           for: indexPath) as! TicketsHeaderCell
            headerCell.seeAllLabel.text = ticketsHeaderCellText()
            let tapGr = UITapGestureRecognizer(target: self,
                                               action: #selector(ticketsHeaderTapped(_:)))
            headerCell.addGestureRecognizer(tapGr)
            return headerCell
        case .tickets:
            let cell = tableView.dequeueReusableCell(withIdentifier: YourTicketsCell.identifier, for: indexPath) as! YourTicketsCell
            cell.order = purchasedOrdersViewModel.purchasedOrder(at: indexPath.row)
            cell.delegate = self
            return cell
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
        case .events:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("What's Happening", comment: "Section title")
            cell.viewModel = eventViewModel
            cell.separatorView.isHidden = false
            cell.layoutStyle = .allBigItems
            return cell
        case .personalize:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalizeCell", for: indexPath)
            return cell
//        case .newAndNotable:
//            let cell = largeCollectionScroller(in: tableView, for: indexPath)
//            cell.titleLabel.text = NSLocalizedString("New and Notable", comment: "Section title")
//            cell.viewModel = newAndNotableViewModel
//            cell.separatorView.isHidden = false
//            cell.layoutStyle = .twoSmallOneBig
//            return cell
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
        if let event = dataItem as? Event {
            guard let vc = UIStoryboard.eventDetail() else { return }
            vc.event = event
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func userTappedTicketsFor(dataItem: DataItem, sender: UITableViewCell) {
        if let venue = dataItem as? Venue,
           let vc = UIStoryboard.ticketForm() {
            vc.venue = venue
            navigationController?.pushViewController(
                vc, animated: true
            )
        }
    }
}


// Protocol extension implementaion for purchased tickets
extension HomeViewController: TableViewCoreDataItemUpdate {}

extension HomeViewController: CoreDataViewModelDelegate {
    func didProcessModelUpdates(sender: CoreDataViewModel) {
        if sender == purchasedOrdersViewModel {
            if showingAllTickets && purchasedOrdersViewModel.numberOfItems < maxTicketsShownWhenCollapsed {
                showingAllTickets = false
            }
            
            let sectionsToChange = IndexSet(integersIn: Range<IndexSet.Element>(NSRange(location: HomeSections.ticketsHeader.rawValue,
                                                                                        length: 2))!)
            tableView?.reloadSections(sectionsToChange,
                                      with: .automatic)
        }
        
        if sender == eventViewModel {
            updateShowingEvents()
        }
    }
}
