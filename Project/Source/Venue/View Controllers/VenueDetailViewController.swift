//
//  VenueDetailViewController.swift
//  Rekall
//
//  Created by Steve on 6/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage
import SafariServices
import PassKit

class VenueDetailViewController: UIViewController {
    
    @IBOutlet var tableView: VenueDetailTableView?
    var timer: Timer?
    
    var updatable: CDUpdateMonitor<Venue>?

    var venue: Venue? {
        set {
            updatable = nil
            if let venue = newValue {
                updatable = CDUpdateMonitor(cdItem: venue) { [weak self] in
                    self?.setupVenueDetails()
                    self?.tableView?.reloadData()
                }
            }

            paymentViewModel.venue = venue
        }
        get {
            return updatable?.cdItem
        }
    }

    var nearbyVenue: Venue?
    var likeShareManager = LikeShareButtonManager()
    let userViewModel = UserViewModel.shared
    let paymentViewModel = PaymentViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let nearbyViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let purchasedOrdersViewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let eventViewModel = EventViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    var dataSource = VenueDetailDataSource()
    
    @IBAction func unwindWebView(unwindSegue: UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never

        setupVenueDetails()
    }
    
    
    func setupVenueDetails() {
        setUpBarItems()
        setUpNearbyViewModel()
        likeShareManager.delegate = self
        dataSource.delegate = self
        dataSource.venue = venue
        setUpPurchasedOrdersViewModel()
        setupEventViewModel()
        setUpTableView()
        paymentViewModel.onTicketOptionsSuccess = { [weak self] in
            self?.updateTicketCell()
        }
        makeTicketRequest()
    }
    
    func setUpPurchasedOrdersViewModel() {
        if let vid = venue?.id {
            dataSource.purchasedOrdersViewModel = purchasedOrdersViewModel
            purchasedOrdersViewModel.coreDataModelDelegate = self
            purchasedOrdersViewModel.dataSection = VenueDetailSections.allPurchasedOrders.rawValue
            purchasedOrdersViewModel.setVenueIdPredicate(vid: vid)
        }
    }
    
    private func setupEventViewModel() {
        if let venue = venue {
            dataSource.eventViewModel = eventViewModel
            eventViewModel.venue = venue
        }
    }
    
    func makeTicketRequest() {
        if let v = venue, v.hasTickets {
            paymentViewModel.loadTicketOptions()
        }
    }
    
    func updateTicketCell() {
        let ticketOptions = paymentViewModel.ticketOptions ?? []
        dataSource.ticketOptions = ticketOptions
        tableView?.reloadData()
    }
    
    func setUpTableView() {
        tableView?.delegate = dataSource
        tableView?.dataSource = dataSource
    }
    
    func setUpNearbyViewModel() {
        let vids = venue?.nearbyIds() ?? []
        nearbyViewModel.venueIds = vids
        dataSource.nearbyViewModel = nearbyViewModel
    }
    
    func setUpBarItems() {
        let venueId = venue?.id ?? ""
        let isFavorited = userViewModel.isFavorited(venueId)
        let buttons = likeShareManager.buttons(isFavorited: isFavorited)
        navigationItem.rightBarButtonItems = buttons
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVenueSegue" {
            if let vc = segue.destination as? VenueDetailViewController {
                vc.venue = nearbyVenue
            }
        }
        
        if let vc = segue.destination as? EventDetailViewController {
            vc.event = sender as? Event
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            self?.updateOpeningClosingTime()
        }
        updateOpeningClosingTime()
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    func updateOpeningClosingTime() {
        updateHoursCellTime()
        updateHeaderTime()
        updateNearbyCellTime()
    }
    
    func updateHoursCellTime() {
        for (i,v) in VenueDetailSections.allCases.enumerated() {
            if v == .hours {
                if let isOpen = venue?.openingHours?.isOpen() {
                    let ip = IndexPath(row: i, section: 0)
                    guard let cell = tableView?.cellForRow(at: ip) as? DetailHoursCell else { return }
                    cell.updateOpenClosed(isOpen:isOpen)
                }
            }
        }
    }
    
    func updateHeaderTime() {
        if let headerView = tableView?.headerView(forSection: 0) as? VenueHeaderView {
            guard let venue = venue else { return }
            headerView.setIsComingSoon(venue: venue)
        }
    }
    
    func updateNearbyCellTime() {
        for (i,v) in VenueDetailSections.allCases.enumerated() {
            if v == .nearby {
                let ip = IndexPath(row: i, section:0)
                guard let cell = tableView?.cellForRow(at: ip) as? HomeHorizontalCollectionCellSmall else { return }
                let visibleCells = cell.collectionView?.visibleCells
                visibleCells?.forEach({ (cell) in
                    let visCell = cell as? HomeHorizontalCellSmall
                    if let item = visCell?.dataItem as? Venue {
                        visCell?.distanceAndTimeLabel.text = item.openingHours?.getNextOpeningOrClosingEventTime()
                    }
                })
            }
        }
    }

}

extension VenueDetailViewController: LikeShareButtonManagerDelegate {
    
    func shareButtonTapped() {
        let shareSheet = UIActivityViewController(
            activityItems: shareItems(), applicationActivities:nil
        )
        present(shareSheet, animated: true, completion: nil)
    }
    
    func likeButtonTapped() {
        if let venueId = venue?.id {
            userViewModel.updateFavorite(venueId)
            setUpBarItems()
        }
    }
    
    func shareItems()->[Any] {
        var items = [Any]()
        let shareItemSource = VenueShareItemSource()
        shareItemSource.venue = venue
        if let cachedImg = venue?.firstCachedImage() {
            items.append(cachedImg)
        }
        items.append(shareItemSource)
        
        return items
    }
    
}

extension VenueDetailViewController: VenueDetailDelegate {

    func tappedActionButton() {
        if let vc = UIStoryboard.ticketForm() {
            vc.venue = venue
            navigationController?.pushViewController(
                vc, animated: true
            )
        }
    }
    
    func tapped(cell: UITableViewCell) {
        if let index = tableView?.indexPath(for: cell), let section = VenueDetailSections(rawValue: index.section) {
            switch section {
            case .location:
                if #available(iOS 13.0, *) {
                    let sb = UIStoryboard(name: "OnSiteMap", bundle: nil)
                    guard let vc = sb.instantiateInitialViewController() as? OnSiteMapViewController else {
                        print("ERROR: Failed to instantiate VC from SB")
                        return
                    }
                    
                    vc.destinationVenue = venue
                    self.tabBarController?.tabBar.isHidden = true
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    showiOS13Required()
                }
            case .contact:
                IntercomManager.shared.launchMessenger()
            case .website:
                if let url = URL(string:venue?.contactDetails?.website ?? "") {
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true, completion: nil)
                }
            case .phone:
                if let phone = venue?.contactDetails?.phoneNo {
                    UIApplication.call(phone: phone)
                }
            case .hours:
                tableView?.reloadRows(at: [index], with: .automatic)
            default:
                break
            }
        }
    }
    
    func tappedVenueOrEvent(dataItem: DataItem) {
        if let nearbyVenue = dataItem as? Venue {
            self.nearbyVenue = nearbyVenue
            performSegue(withIdentifier: "ShowVenueSegue", sender: self)
        }
        
        if let event = dataItem as? Event {
            performSegue(withIdentifier: "ShowEventSegue", sender: event)
        }
    }
    
    func tappedTickets(dataItem: DataItem) {
        if  let nearbyVenue = dataItem as? Venue,
            let vc = UIStoryboard.ticketForm() {
                vc.venue = nearbyVenue
                navigationController?.pushViewController(
                    vc, animated: true
                )
        }
    }
    
    func tappedPurchasedOrder(cell: YourTicketsCell) {
        if let index = tableView?.indexPath(for: cell), let vc = UIStoryboard.ticketDetail() {
            let ticket = purchasedOrdersViewModel.purchasedOrder(at: index.row)
            vc.order = ticket
            vc.venue = venue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension VenueDetailViewController: CoreDataViewModelDelegate {
    
    func didProcessModelUpdates(sender: CoreDataViewModel) {
        let headerSection = VenueDetailSections.ticketsHeader.rawValue
        let section = VenueDetailSections.allPurchasedOrders.rawValue
        let set = IndexSet(integersIn: headerSection...section)
        tableView?.reloadSections(set, with: .automatic)
    }
    
}
