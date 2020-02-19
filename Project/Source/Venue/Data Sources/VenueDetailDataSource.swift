//
//  VenueDetailDataSource.swift
//  Rekall
//
//  Created by Steve on 7/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum VenueDetailSections: Int, CaseIterable {
    case location
    case hours
    case contact
    case phone
    case website
}

protocol VenueDetailDelegate: class {
    func tappedActionButton()
    func tapped(cell: UITableViewCell)
    func tappedVenueOrEvent(dataItem: DataItem)
}

class VenueDetailDataSource: NSObject {

    var venue: Venue?
    weak var delegate: VenueDetailDelegate?
    var isHoursExpanded = false
    
    var estHeaderHeight: CGFloat = 540.0
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
        case .location:
            return (venue?.locationDescription == nil) ? 0 : 1
        case .hours:
            return (venue?.openingHours == nil || venue?.comingSoon == true) ? 0 : 1
        case .website:
            return (venue?.contactDetails?.website == nil) ? 0 : 1
        case .phone:
            return (venue?.contactDetails?.phoneNo == nil) ? 0 : 1
        case .contact:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = VenueDetailSections(rawValue: indexPath.section) else {
            fatalError("No venue detail section")
        }
        
        switch section {
        case .location:
            let link = venue?.locationDescription ?? ""
            let title = NSLocalizedString("Location", comment: "Cell title")
            return configCell(link: link, title: title, addColor: true, tv: tableView, ip: indexPath)
        case .hours:
            return configCellHours(tv: tableView, ip: indexPath)
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
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil //fixes an issue w/footers showing for every section
    }
        
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01 //fixes an issue w/footers showing for every section
    }
    
}

extension VenueDetailDataSource {
    
    func configTicketHeaderCell(tv: UITableView, ip: IndexPath)->YourTicketsHeaderCell {
        return tv.dequeueReusableCell(withIdentifier: YourTicketsHeaderCell.identifier, for: ip) as! YourTicketsHeaderCell
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
}
