//
//  EventViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreData
import Moya

class EventViewModel: CoreDataViewModel {
        
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    var searchText: String? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    var venue: Venue? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    private var nextImportOrdinal: Int32 = 0
    
    func createPredicate() -> NSPredicate? {
        if let searchText = searchText {
            return NSPredicate(format: "name contains[cd] %@", searchText)
        }
        if let venueId = venue?.id {
            return NSPredicate(format: "venueId == %@", venueId)
        }
        
        return nil
    }
    
    func updateResultsControllerWith(predicate: NSPredicate?){
        resultsController.fetchRequest.predicate = predicate
        
        do {
            try resultsController.performFetch()
        } catch {
            print("ERROR: performFetch() failed")
        }
    }

    lazy private(set) var resultsController: NSFetchedResultsController<Event> = {
        let fr: NSFetchRequest<Event> = Event.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "importOrdinal", ascending: true)]
        fr.predicate = createPredicate()
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: ADPersistentContainer.shared.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("ERROR: performFetch() failed")
        }
        return frc
    }()
        
    var loadingData = false
    let eventsPerCall = 50
    func loadEvents() {
        if loadingData {
            return
        }
        
        nextImportOrdinal = 0
        let eventRequest = EventRequest(skip: 0, limit: eventsPerCall)
        makeRequest(eventRequest)
    }
    
    private func loadMore() {
        print("Loading more events")
        let eventRequest = EventRequest(skip: Int(nextImportOrdinal), limit: eventsPerCall)
        makeRequest(eventRequest)
    }
    
    func makeRequest(_ eventRequest:EventRequest) {
        ADPersistentContainer.shared.save()
        if loadingData { return }
        loadingData = true
        request(eventRequest) { result in
            switch result {
            case .success(let results):
                let nrEventsLoaded = self.processApiResponse(response: results)
                
                DispatchQueue.main.async {
                    self.loadingData = false

                    ADPersistentContainer.shared.save()

                    if nrEventsLoaded == self.eventsPerCall {
                        self.loadMore()
                    } else {
                        self.onUpdateSuccess?()
                    }
                }
                
            case .failure(let error):
                print("Failure: \(error)")
                DispatchQueue.main.async {
                    self.loadingData = false
                    self.onUpdateFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processApiResponse(response: Moya.Response) -> Int {
        do {
            let workMoc = ADPersistentContainer.shared.childContext

            if nextImportOrdinal == 0 {
                let fr: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
                fr.includesPropertyValues = false
                if let existingEvents = try workMoc.fetch(fr) as? [Event] {
                    for e in existingEvents {
                        workMoc.delete(e)
                    }
                }
            }
            
            guard let parsedJson = try JSONSerialization.jsonObject(with: response.data, options: []) as? Dictionary<String, Any>,
            let eventItems = parsedJson["data"] as? [Dictionary<String, Any>] else {
                return 0
            }
            
            for eventItem in eventItems {
                let eventData = try JSONSerialization.data(withJSONObject: eventItem, options: [])
                let event = try decodeData(Event.self, data: eventData, moc: workMoc)
                
                if let object = eventItem["object"] as? Dictionary<String, Any>,
                let fields = object["fields"] as? Dictionary<String, Any> {
                    try storeContentful(fields: fields, in: event)
                }
                
                event.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1
            }

            try workMoc.save()
            return eventItems.count
        } catch {
            print("ERROR in processApiResponse: \(error)")
            return 0
        }
    }
    
    func storeContentful(fields: Dictionary<String, Any>, in event: Event) throws {
        if let body = fields["body"] as? Dictionary<String, Any>,
        let enUS = body["en-US"] {
            let objectData = try JSONSerialization.data(withJSONObject: enUS,
                                                        options: [])
            event.contentfulData = objectData
        }

        if let displayDate = fields["displayDate"] as? Dictionary<String, String>,
        let displayDateEnUs = displayDate["en-US"] {
            event.displayDate = displayDateEnUs
        }


        if let shortDescription = fields["shortDescription"] as? Dictionary<String, String>,
        let shortDescriptionEnUs = shortDescription["en-US"] {
            event.itemShortDescription = shortDescriptionEnUs
        }
        
        if let horizontalImage = fields["horizontalImage"] as? Dictionary<String, Any>,
        let enUS = horizontalImage["en-US"] as? Dictionary<String, Any>,
        let fields = enUS["fields"]as? Dictionary<String, Any> ,
        let file = fields["file"] as? Dictionary<String, Any>,
        let enUs2 = file["en-US"] as? Dictionary<String, Any>,
        let urlField = enUs2["url"] as? String,
        let fullUrl = URL(string: "https:" + urlField) {
            event.imageUrls = [fullUrl]
        }
    }
    
    func event(at index: Int) -> Event? {
        let indexPath = IndexPath(item: index, section: 0)
        return resultsController.object(at: indexPath)
    }
}

extension EventViewModel: DataItemProvider {
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }

    func item(at index: Int) -> DataItem? {
        return event(at: index)
    }
}
