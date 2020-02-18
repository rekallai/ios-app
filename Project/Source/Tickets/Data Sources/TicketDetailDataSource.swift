//
//  TicketDetailDataSource.swift
//  Rekall
//
//  Created by Steve on 9/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum TicketDetailSections: Int, CaseIterable {
    case orderNumber
    case orderDate
    case orderName
    case hours
    case location
    case goodToKnow
    case phone
}

protocol TicketDetailDelegate: class {
    func tappedPassButton()
    func tapped(cell: UITableViewCell)
    func ticketChanged()
}

class TicketDetailDataSource: NSObject {
    weak var delegate: TicketDetailDelegate?
    var order: PurchasedOrder? {
        didSet {
            currentTicket = order?.tickets?.first
        }
    }
    var venue: Venue?
    var estHeaderHeight: CGFloat = 540.0
    var isHoursExpanded = false
    var currentTicket: PurchasedTicket?
}

extension TicketDetailDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TicketDetailSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = TicketDetailSections(rawValue: section) else { return 1 }
        
        switch section {
        case .orderNumber:
            return (currentTicket?.issuedCode != nil) ? 1 : 0
        case .orderDate:
            return (order?.startsAt != nil) ? 1 : 0
        case .orderName:
            return (order != nil) ? 1 : 0
        case .hours:
            return (venue?.openingHours != nil) ? 1 : 0
        case .location:
            return (venue?.locationDescription != nil) ? 1 : 0
        case .goodToKnow:
            let isAttrEmpty = venue?.attributes?.isEmpty ?? true
            return (venue?.attributes != nil && !isAttrEmpty) ? 1 : 0
        case .phone:
            return (venue?.contactDetails?.phoneNo != nil) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = TicketDetailSections(rawValue: indexPath.section) else {
            fatalError("No ticket detail section")
        }
        
        switch section {
        case .orderNumber:
            return configOrderNumberCell(tv: tableView, ip: indexPath)
        case .orderDate:
            return configOrderDateCell(tv: tableView, ip: indexPath)
        case .orderName:
            return configOrderNameCell(tv: tableView, ip: indexPath)
        case .hours:
            return configHoursCell(tv: tableView, ip: indexPath)
        case .location:
            return configLocationCell(tv: tableView, ip: indexPath)
        case .goodToKnow:
            return configGoodToKnowCell(tv: tableView, ip: indexPath)
        case .phone:
            return configPhoneCell(tv: tableView, ip: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = TicketDetailSections(rawValue: indexPath.section) else { return }
        
        switch section {
        case .location, .phone:
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let section = TicketDetailSections(rawValue: section) else { return nil }
        
        switch section {
        case .orderNumber:
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TicketHeaderView.identifier) as! TicketHeaderView
            
            if let venue = venue {
                view.delegate = self
                view.order = order
                view.venue = venue
                view.contentView.backgroundColor = UIColor(named: "WhiteBlack")
            }
    
            return view
        case .hours, .goodToKnow:
            let view = UIView()
            view.backgroundColor = .clear
            return view
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //resolves issue of jerky scrolling after expanding hours cell
        guard let section = TicketDetailSections(rawValue: section) else { return }
        if section == .orderNumber {
            estHeaderHeight = view.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        //resolves issue of jerky scrolling after expanding hours cell
        guard let section = TicketDetailSections(rawValue: section) else { return 0.01 }
        return (section == .orderNumber) ? estHeaderHeight : 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = TicketDetailSections(rawValue: section) else { return 0.0 }
        switch section {
        case .goodToKnow, .hours:
            return 18.0
        case .orderNumber:
            return UITableView.automaticDimension
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = TicketDetailSections(rawValue: section) else { return nil }
        if section == .phone {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = TicketDetailSections(rawValue: section) else { return 0.01 }
        if section == .phone {
            return 60.0
        } else { return 0.01 }
    }
    
}

extension TicketDetailDataSource {
    
    func configOrderNumberCell(tv: UITableView, ip: IndexPath)->TicketDetailCell {
        let cell = tv.dequeueReusableCell(withIdentifier: TicketDetailCell.identifier, for: ip) as! TicketDetailCell
        let title = NSLocalizedString("Order Number", comment: "Title")
        let issuedCode = currentTicket?.issuedCode ?? ""
        cell.leftLabel.text = title
        cell.rightLabel.text = issuedCode
        return cell
    }
    
    func configOrderDateCell(tv: UITableView, ip: IndexPath)->TicketDetailCell {
        let cell = tv.dequeueReusableCell(withIdentifier: TicketDetailCell.identifier, for: ip) as! TicketDetailCell
        if let order = order {
            cell.leftLabel.text = NSLocalizedString("Date", comment: "Title")
            cell.rightLabel.text = order.startsAt?.longDayMonth()
        }
        return cell
    }
    
    func configOrderNameCell(tv: UITableView, ip: IndexPath)->TicketDetailCell {
        let cell = tv.dequeueReusableCell(withIdentifier: TicketDetailCell.identifier, for: ip) as! TicketDetailCell
        let user = UserViewModel.shared.user
        cell.leftLabel.text = NSLocalizedString("Name", comment: "Title")
        cell.rightLabel.text = "\(user.firstName) \(user.lastName)"
        return cell
    }
    
    func configHoursCell(tv: UITableView, ip: IndexPath)->DetailHoursCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailHoursCell.identifier, for: ip) as! DetailHoursCell
        cell.set(openingHours: venue?.openingHours, isExpanded: isHoursExpanded)
        cell.delegate = self
        return cell
    }
    
    func configLocationCell(tv: UITableView, ip: IndexPath)->DetailLinkCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailLinkCell.identifier, for: ip) as! DetailLinkCell
        
        if let location = venue?.locationDescription {
            let title = NSLocalizedString("Location", comment: "Cell title")
            cell.titleLabel?.text = title
            cell.setLink(text: location, addColor: true)
        }
        
        return cell
    }
    
    func configGoodToKnowCell(tv: UITableView, ip: IndexPath)->DetailPointCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailPointCell.identifier, for: ip) as! DetailPointCell
        
        if let attrs = venue?.attributes {
            let title = NSLocalizedString("Good to Know", comment: "Cell title")
            cell.addLabels(attrs, title: title)
        }
        
        return cell
    }
    
    func configPhoneCell(tv: UITableView, ip: IndexPath)->DetailLinkCell {
        let cell = tv.dequeueReusableCell(withIdentifier: DetailLinkCell.identifier, for: ip) as! DetailLinkCell
        
        if let phoneNumber = venue?.contactDetails?.phoneNo {
            let title = NSLocalizedString("Phone", comment: "Cell title")
            cell.titleLabel?.text = title
            cell.setLink(text: phoneNumber, addColor: false)
        }
        
        return cell
    }
    
}

extension TicketDetailDataSource: TicketHeaderViewDelegate {
    
    func tappedPassButton() {
        delegate?.tappedPassButton()
    }
    
    func sliderChanged(ticket: PurchasedTicket) {
        currentTicket = ticket
        delegate?.ticketChanged()
    }
    
}

extension TicketDetailDataSource: DetailHoursCellDelegate {
    
    func tappedDetailHours(cell: DetailHoursCell) {
        isHoursExpanded = !isHoursExpanded
        delegate?.tapped(cell: cell)
    }
    
}
