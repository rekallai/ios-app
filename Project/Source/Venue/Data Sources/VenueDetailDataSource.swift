//
//  VenueDetailDataSource.swift
//  Rekall
//
//  Created by Steve on 7/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum VenueDetailSections: Int, CaseIterable {
    case ticketsHeader
    case allPurchasedOrders
    case ticketOptions
    case location
    case hours
    case goodToKnow
    case events
    case contact
    case phone
    case website
    case nearby
}

protocol VenueDetailDelegate: class {
    func tappedActionButton()
    func tapped(cell: UITableViewCell)
    func tappedVenueOrEvent(dataItem: DataItem)
    func tappedTickets(dataItem: DataItem)
    func tappedPurchasedOrder(cell: YourTicketsCell)
}

class VenueDetailDataSource: NSObject {

    var venue: Venue?
    var ticketOptions = [TicketOption]()
    weak var delegate: VenueDetailDelegate?
    var isHoursExpanded = false
    var nearbyViewModel: VenueViewModel?
    var purchasedOrdersViewModel: PurchasedOrdersViewModel?
    var eventViewModel: EventViewModel?
    
    var estHeaderHeight: CGFloat = 540.0
    
    private func ticketItems()->[String] {
        return ticketOptions.map({ (ticket) -> String in
            "\(ticket.priceUsd.dollarString) \(ticket.name)"
        })
    }
    
}

extension VenueDetailDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return VenueDetailSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = VenueDetailSections(rawValue: section) else {
            fatalError("No venue detail section")
        }
        
        switch section {
        case .ticketsHeader:
            if let purchasedOrdersViewModel = purchasedOrdersViewModel {
                let count = purchasedOrdersViewModel.numberOfItems
                return (count > 0) ? 1 : 0
            } else { return 0 }
        case .allPurchasedOrders:
            if let purchasedOrdersViewModel = purchasedOrdersViewModel {
                return purchasedOrdersViewModel.numberOfItems
            } else { return 0 }
        case .ticketOptions:
            let hasTickets = venue?.hasTickets ?? false
            return !ticketOptions.isEmpty && hasTickets ? 1 : 0
        case .location:
            return (venue?.locationDescription == nil) ? 0 : 1
        case .hours:
            return (venue?.openingHours == nil || venue?.comingSoon == true) ? 0 : 1
        case .goodToKnow:
            let isAttrEmpty = venue?.attributes?.isEmpty ?? true
            return (venue?.attributes == nil || isAttrEmpty) ? 0 : 1
        case .events:
            return (eventViewModel?.numberOfItems ?? 0) > 0 ? 1 : 0
        case .website:
            return (venue?.contactDetails?.website == nil) ? 0 : 1
        case .phone:
            return (venue?.contactDetails?.phoneNo == nil) ? 0 : 1
        case .nearby:
            let count = nearbyViewModel?.numberOfItems ?? 0
            return (count > 0) ? 1 : 0
        case .contact:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = VenueDetailSections(rawValue: indexPath.section) else {
            fatalError("No venue detail section")
        }
        
        switch section {
        case .ticketsHeader:
            return configTicketHeaderCell(tv: tableView, ip: indexPath)
        case .allPurchasedOrders:
            return configYourTicketCell(tv: tableView, ip: indexPath)
        case .ticketOptions:
            let title = NSLocalizedString("Tickets", comment: "Cell title")
            return configCell(items: ticketItems(), title: title, tv: tableView, ip: indexPath)
        case .location:
            let link = venue?.locationDescription ?? ""
            let title = NSLocalizedString("Location", comment: "Cell title")
            return configCell(link: link, title: title, addColor: true, tv: tableView, ip: indexPath)
        case .hours:
            return configCellHours(tv: tableView, ip: indexPath)
        case .goodToKnow:
            let items = venue?.attributes ?? []
            let title = NSLocalizedString("Good to Know", comment: "Cell title")
            return configCell(items: items, title: title, tv: tableView, ip: indexPath)
        case .events:
            return configCellEvents(tv: tableView, ip: indexPath)
        case .contact:
            return configContactCell(tv: tableView, ip: indexPath)
        case .phone:
            let link = venue?.contactDetails?.phoneNo ?? ""
            let title = NSLocalizedString("Phone", comment: "Cell title")
            return configCell(link: link, title: title, addColor: false, tv: tableView, ip: indexPath)
        case .website:
            let link = venue?.contactDetails?.website ?? ""
            let title = NSLocalizedString("Website", comment: "Cell title")
            return configCell(link: link, title: title, addColor: false, tv: tableView, ip: indexPath)
        case .nearby:
            return configCellNearby(tv: tableView, ip: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = VenueDetailSections(rawValue: indexPath.section) else { return }
        
        switch section {
        case .contact, .website, .location, .phone:
            if let cell = tableView.cellForRow(at: indexPath) {
                delegate?.tapped(cell: cell)
            }
        case .hours:
            if let cell = tableView.cellForRow(at: indexPath) {
                isHoursExpanded = !isHoursExpanded
                delegate?.tapped(cell: cell)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //resolves issue of jerky scrolling after expanding hours cell
        guard let section = VenueDetailSections(rawValue: section) else { return }
        if section == .ticketsHeader {
            estHeaderHeight = view.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        //resolves issue of jerky scrolling after expanding hours cell
        guard let section = VenueDetailSections(rawValue: section) else { return 0.01 }
        if section == .ticketsHeader {
            return estHeaderHeight
        } else { return 0.01 }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = VenueDetailSections(rawValue: section) else { return nil }
        if section == .ticketsHeader {
            let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: VenueHeaderView.identifier
            ) as? VenueHeaderView
            view?.delegate = self
            view?.venue = venue
            return view
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil //fixes an issue w/footers showing for every section
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = VenueDetailSections(rawValue: section) else { return 0.0 }
        return (section == .ticketsHeader) ? UITableView.automaticDimension : 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01 //fixes an issue w/footers showing for every section
    }
    
}

extension VenueDetailDataSource {
    
    func configTicketHeaderCell(tv: UITableView, ip: IndexPath)->YourTicketsHeaderCell {
        return tv.dequeueReusableCell(withIdentifier: YourTicketsHeaderCell.identifier, for: ip) as! YourTicketsHeaderCell
    }
    
    func configYourTicketCell(tv: UITableView, ip: IndexPath)->YourTicketsCell {
        let ticket = purchasedOrdersViewModel?.purchasedOrder(at: ip.row)
        let cell = tv.dequeueReusableCell(withIdentifier: YourTicketsCell.identifier, for: ip) as! YourTicketsCell
        cell.order = ticket
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func configCell(link: String, title: String, addColor: Bool, tv: UITableView, ip: IndexPath)->DetailLinkCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailLinkCell.identifier, for: ip) as! DetailLinkCell
        cell.titleLabel?.text = title
        cell.setLink(text: link, addColor: addColor)
        return cell
    }
    
    func configContactCell(tv: UITableView, ip: IndexPath)->DetailContactCell {
        return tv.dequeueReusableCell(withIdentifier: DetailContactCell.identifier, for: ip) as! DetailContactCell
    }
    
    func configCell(items: [String], title: String, tv: UITableView, ip: IndexPath)->DetailPointCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailPointCell.identifier, for: ip) as! DetailPointCell
        cell.addLabels(items, title: title)
        return cell
    }
    
    func configCellHours(tv: UITableView, ip: IndexPath)->DetailHoursCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailHoursCell.identifier, for: ip) as! DetailHoursCell
        cell.set(openingHours: venue?.openingHours, isExpanded: isHoursExpanded)
        cell.delegate = self
        return cell
    }
    
    func configCellNearby(tv: UITableView, ip: IndexPath)->HomeHorizontalCollectionCellSmall {
        let cell = tv.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellSmall.identifier, for: ip) as! HomeHorizontalCollectionCellSmall
        cell.titleLabel?.text = NSLocalizedString("What's Nearby", comment: "Cell title")
        cell.viewModel = nearbyViewModel
        cell.delegate = self
        cell.seperatorLine.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    
    func configCellEvents(tv: UITableView, ip: IndexPath)->UITableViewCell {
        if eventViewModel?.numberOfItems == 1 {
            let cell = tv.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellLarge.identifier, for: ip)
                as! HomeHorizontalCollectionCellLarge
            cell.titleLabel?.text = NSLocalizedString("Event", comment: "Cell title")
            cell.thickSeparator = false
            cell.viewModel = eventViewModel
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        
        assert(eventViewModel?.numberOfItems != 1)
        
        let cell = tv.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellSmall.identifier, for: ip)
            as! HomeHorizontalCollectionCellSmall
        cell.titleLabel?.text = NSLocalizedString("Events", comment: "Cell title")
        cell.thickSeparator = false
        cell.viewModel = eventViewModel
        cell.delegate = self
        cell.selectionStyle = .none
        return cell

    }
}

extension VenueDetailDataSource: VenueHeaderViewDelegate {
    
    func tappedActionButton() {
        delegate?.tappedActionButton()
    }
    
}

extension VenueDetailDataSource: DetailHoursCellDelegate {
    
    func tappedDetailHours(cell: DetailHoursCell) {
        isHoursExpanded = !isHoursExpanded
        delegate?.tapped(cell: cell)
    }
    
}

extension VenueDetailDataSource: HomeHorizontalCollectionDelegate {
    
    func userTapped(dataItem: DataItem, sender: UITableViewCell) {
        delegate?.tappedVenueOrEvent(dataItem: dataItem)
    }
 
    func userTappedTicketsFor(dataItem: DataItem, sender: UITableViewCell) {
        delegate?.tappedTickets(dataItem: dataItem)
    }
}

extension VenueDetailDataSource: YourTicketsCellDelegate {
    
    func tapped(cell: YourTicketsCell) {
        delegate?.tappedPurchasedOrder(cell: cell)
    }
    
}
