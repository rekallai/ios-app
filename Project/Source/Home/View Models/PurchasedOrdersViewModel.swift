//
//  PurchasedOrdersViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 02/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreData
import Moya

class PurchasedOrdersViewModel: CoreDataViewModel {
    
    var onUpdateSuccess:(() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    var predicate:NSPredicate?

    lazy private(set) var resultsController: NSFetchedResultsController<PurchasedOrder> = {
        let fr:NSFetchRequest<PurchasedOrder> = PurchasedOrder.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "startsAt", ascending: true)]
        if let predicate = predicate {
            fr.predicate = predicate
        }
        let frc = NSFetchedResultsController(
            fetchRequest: fr,
            managedObjectContext: ADPersistentContainer.shared.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        frc.delegate = self
        
        do{
            try frc.performFetch()
        } catch {
            print("Error with performFetch()")
        }
        return frc
    }()
    
    func setFuturePredicate() {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.startOfDay(for: Date()) as NSDate
        predicate = NSPredicate(format: "startsAt >= %@", today)
    }
    
    func setVenueIdPredicate(vid: String) {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.startOfDay(for: Date()) as NSDate
        let datePredicate = NSPredicate(format: "startsAt >= %@", today)
        let venuePredicate = NSPredicate(format: "venueId == %@", vid)
        predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, venuePredicate])
    }
    
    func purchasedOrder(at index: Int) -> PurchasedOrder? {
        let indexPath = IndexPath(item: index, section: 0)
        return resultsController.object(at: indexPath)
    }
    
    func reloadTicketsFromBackend() {
        let req = APIRequestCurrentUserTickets()
        request(req) { result in
            switch result {
            case .success(let response):
                self.processTicketsResponse(response: response)
            case .failure(let error):
                print("ERROR: Tickets update failed")
                DispatchQueue.main.async {
                    self.onUpdateFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processTicketsResponse(response: Moya.Response) {
        do {
            let workMoc = ADPersistentContainer.shared.childContext

            let ticketsResponse = try decodeResponse(APIResponseCurrentUserTickets.self,
                                                     response: response,
                                                     moc: workMoc)

            let fr: NSFetchRequest<NSFetchRequestResult> = PurchasedOrder.fetchRequest()
            fr.includesPropertyValues = false
            if let existingTickets = try workMoc.fetch(fr) as? [PurchasedOrder] {
                for ticket in existingTickets {
                    workMoc.delete(ticket)
                }
            }
            
            //
            // All tickets options come down at once, so group by orderId, then add the whole order as single
            // purchased order
            //
            var ticketsByOrderId = [String: [APIResponseCurrentUserTickets.ResponseTicket]]()
            
            for ticket in ticketsResponse.data {
                if ticketsByOrderId[ticket.orderId] == nil {
                    ticketsByOrderId[ticket.orderId] = [ticket]
                } else {
                    ticketsByOrderId[ticket.orderId]!.append(ticket)
                }
            }
            
            LocalNotificationManager.shared.removePendingNotifications()
            
            //
            // Just add into MOC, let UI pull using fetched results controllers
            //
            for (_, tickets) in ticketsByOrderId {
                let order = PurchasedOrder(context: workMoc, sourceTickets: tickets)
                LocalNotificationManager.shared.scheduleNotificationFor(order: order)
            }
                        
            try workMoc.save()
            
            DispatchQueue.main.async {
                ADPersistentContainer.shared.save()
                self.onUpdateSuccess?()
            }
        } catch {
            print("Error processing purchased ticket api response: \(error)")
            
            DispatchQueue.main.async {
                self.onUpdateFailure?(error.localizedDescription)
            }
        }
    }
}

extension PurchasedOrdersViewModel: DataItemProvider {
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
    
    func item(at index: Int) -> DataItem? {
        return purchasedOrder(at: index)
    }
}
