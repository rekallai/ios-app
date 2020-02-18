//
//  PurchasedOrder+CoreDataClass.swift
//  Rekall
//
//  Created by Steve on 7/17/19.
//  Copyright © 2020 Rekall. All rights reserved.
//
//

import Foundation
import CoreData

@objc
public class PurchasedTicket: NSObject, Codable, NSCoding {
    
    let id: String
    let issuedCode: String
    let orderId: String
    let passkitAuthorizationToken: String

    // Ticket Option Info
    let date: Date
    let name: String
    let price: Int
    let tax: Int
    let quantity: Int
    let venueId: String
    
    enum ArchiveKeys: String {
        case id
        case issuedCode
        case orderId
        case passkitAuthorizationToken
        
        case date
        case name
        case price
        case tax
        case quantity
        case venueId
    }
    
    init(orderTicket: ConfirmedOrder.Ticket) {
        id = orderTicket.id
        issuedCode = orderTicket.issuedCode
        orderId = orderTicket.orderId
        passkitAuthorizationToken = orderTicket.passkitAuthorizationToken

        date = DateFormatter.yearMonthDayGmt.date(from: orderTicket.ticketOption.date) ?? Date() // ToDo
        name = orderTicket.ticketOption.name
        price = orderTicket.ticketOption.price
        tax = orderTicket.ticketOption.tax
        quantity = orderTicket.ticketOption.quantity
        venueId = orderTicket.ticketOption.venueId
    }
    
    init(orderTicket: APIResponseCurrentUserTickets.ResponseTicket) {
        id = orderTicket.id
        issuedCode = orderTicket.issuedCode
        orderId = orderTicket.orderId
        passkitAuthorizationToken = orderTicket.passkitAuthorizationToken

        date = DateFormatter.yearMonthDayGmt.date(from: orderTicket.ticketOption.date) ?? Date() // ToDo
        name = orderTicket.ticketOption.name
        price = orderTicket.ticketOption.price
        tax = orderTicket.ticketOption.tax
        quantity = orderTicket.ticketOption.quantity
        venueId = orderTicket.ticketOption.venueId
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: ArchiveKeys.id.rawValue)
        coder.encode(issuedCode, forKey: ArchiveKeys.issuedCode.rawValue)
        coder.encode(orderId, forKey: ArchiveKeys.orderId.rawValue)
        coder.encode(passkitAuthorizationToken, forKey: ArchiveKeys.passkitAuthorizationToken.rawValue)

        coder.encode(date, forKey: ArchiveKeys.date.rawValue)
        coder.encode(name, forKey: ArchiveKeys.name.rawValue)
        coder.encode(price, forKey: ArchiveKeys.price.rawValue)
        coder.encode(tax, forKey: ArchiveKeys.tax.rawValue)
        coder.encode(quantity, forKey: ArchiveKeys.quantity.rawValue)
        coder.encode(venueId, forKey: ArchiveKeys.venueId.rawValue)
    }
    
    required public init?(coder: NSCoder) {
        do {
            id = try (coder.decodeObject(forKey: ArchiveKeys.id.rawValue) as? String).unwrapOrThrow()
            issuedCode = try (coder.decodeObject(forKey: ArchiveKeys.issuedCode.rawValue) as? String).unwrapOrThrow()
            orderId = try (coder.decodeObject(forKey: ArchiveKeys.orderId.rawValue) as? String).unwrapOrThrow()
            passkitAuthorizationToken = try (coder.decodeObject(forKey: ArchiveKeys.passkitAuthorizationToken.rawValue) as? String).unwrapOrThrow()

            date = try (coder.decodeObject(forKey: ArchiveKeys.date.rawValue) as? Date).unwrapOrThrow()
            name = try (coder.decodeObject(forKey: ArchiveKeys.name.rawValue) as? String).unwrapOrThrow()
            price = coder.decodeInteger(forKey: ArchiveKeys.price.rawValue)
            tax = coder.decodeInteger(forKey: ArchiveKeys.tax.rawValue)
            quantity = coder.decodeInteger(forKey: ArchiveKeys.quantity.rawValue)
            venueId = try (coder.decodeObject(forKey: ArchiveKeys.venueId.rawValue) as? String).unwrapOrThrow()
        } catch {
            return nil
        }
    }
}


@objc
public class PurchasedOrder: NSManagedObject, Decodable, DataItem {
    var itemDescription: String?
        
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case venueId
        case orderId
        case paidAmountUsd
        case passkitAuthorizationToken
        case status
        case createdAt
        case updatedAt
    }

    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(context: NSManagedObjectContext,
                     venue: Venue,
                     confirmedOrder: ConfirmedOrder) {
        self.init(context: context)
        
        venueName = venue.name
        imageUrls = venue.imageUrls
        venueId = venue.id
        
        var totalTickets = 0
        tickets = []
        for orderTicket in confirmedOrder.tickets {
            let purchasedTicket = PurchasedTicket(orderTicket: orderTicket)
            tickets?.append(purchasedTicket)
            totalTickets += orderTicket.ticketOption.quantity
            
            self.orderId = orderTicket.orderId
            startsAt = DateFormatter.yearMonthDayGmt.date(from: orderTicket.ticketOption.date)
        }
        
        setTaglineForNumberOfPeople(nrPeople: totalTickets)
    }
    
    
    convenience init(context: NSManagedObjectContext,
                     sourceTickets: [APIResponseCurrentUserTickets.ResponseTicket]) {
        self.init(context: context)
                
        var totalTickets = 0
        tickets = []
        for ticket in sourceTickets {
            let purchasedTicket = PurchasedTicket(orderTicket: ticket)
            tickets?.append(purchasedTicket)
            totalTickets += ticket.ticketOption.quantity
            
            self.orderId = ticket.orderId
            self.venueName = ticket.venue.name
            if ticket.venue.iosImages.count > 0 {
                self.imageUrls = ticket.venue.iosImages.compactMap{ return $0.imageUrl }
            } else {
                self.imageUrls = ticket.venue.images.compactMap{ return $0.imageUrl }
            }
            self.venueId = ticket.venue.id
            self.startsAt = DateFormatter.yearMonthDayGmt.date(from: ticket.ticketOption.date) ?? Date() // ToDo
        }
        
        setTaglineForNumberOfPeople(nrPeople: totalTickets)
    }
    
    
    func setTaglineForNumberOfPeople(nrPeople: Int) {
        self.tagline = nrPeople == 1 ?
            NSLocalizedString("Ticket for 1 person", comment: "Ticket count text") :
            NSLocalizedString("Tickets for \(nrPeople) people", comment: "Ticket count text")
    }

    
    public required init(from decoder: Decoder) throws {
        
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "PurchasedOrder", in: moc) else {
            fatalError("MOC not set in decoder")
        }
        super.init(entity: entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.venueId = try container.decodeIfPresent(String.self, forKey: .venueId)
        self.orderId = try container.decodeIfPresent(String.self, forKey: .orderId)
    }
    
    
    func totalNumberOfTickets() -> Int {
        guard let tickets = tickets else {
            return 0
        }
        
        var totalTickets = 0
        
        for ticket in tickets {
            totalTickets += ticket.quantity
        }
        
        return totalTickets
    }
    
    
    static func removeAllStoredTickets(moc: NSManagedObjectContext) {
        do {
            let fr: NSFetchRequest<PurchasedOrder> = fetchRequest()
            fr.includesPropertyValues = false
            let existingTickets = try moc.fetch(fr)
            for ticket in existingTickets {
                moc.delete(ticket)
            }
            
            try moc.save()
        } catch {
            print("ERROR: Failed while deleting existing tickets: \(error)")
        }
    }
    
    var name: String? { return venueName }
    var itemShortDescription: String? { return nil }
    var itemTag: String? { return nil }
}


extension PurchasedOrder: CDUpdatable {
    func equivalentObjectComparator() -> ((PurchasedOrder) -> Bool) {
        return { [orderId, venueId] other in
            return orderId == other.orderId && venueId == other.venueId
        }
    }
}
