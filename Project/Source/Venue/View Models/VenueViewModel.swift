//
//  VenueViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

import UIKit
import Moya
import CoreData

class VenueViewModel: CoreDataViewModel {
    
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    //
    // The type of venue this view model represents
    //
    enum VenueType: String {
        case shopping
        case restaurant
        case hall
        case attraction
        case newAndNotable
    }
    
    var category: String? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    var venueType: VenueType? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    var searchText: String? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    var venueIds: [String]? {
        didSet {
            updateResultsControllerWith(predicate: createPredicate())
        }
    }
    
    func updateResultsControllerWith(predicate: NSPredicate?){
        resultsController.fetchRequest.predicate = predicate
        
        do {
            try resultsController.performFetch()
        } catch {
            print("ERROR: performFetch() failed")
        }
    }
    
    var sortDescriptors = [NSSortDescriptor(key: "importOrdinal", ascending: true)]
    func createPredicate() -> NSPredicate? {
        if let category = category {
            return NSPredicate(format: "ANY categories.name LIKE[cd] %@", category)
        }
        if let venueType = venueType {
            return NSPredicate(format: "venueType LIKE[cd] %@", venueType.rawValue)
        }
        if let searchText = searchText {
            return NSPredicate(format: "name contains[cd] %@", searchText)
        }
        if let venueIds = venueIds {
            return NSPredicate(format: "id IN %@", venueIds)
        }
        
        return nil
    }
    
    private var nextImportOrdinal: Int32 = 0
    
    lazy private(set) var resultsController: NSFetchedResultsController<Venue> = {
        let fr: NSFetchRequest<Venue> = Venue.fetchRequest()
        fr.sortDescriptors = sortDescriptors
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
    let venuesPerCall = 50
    func loadVenues() {
        if loadingData {
            print("ERROR: Venue VM loadVenues: already loading data")
            return
        }

        nextImportOrdinal = 0
        let venueRequest = VenueRequest(skip: Int(nextImportOrdinal), limit: venuesPerCall)
        makeRequest(venueRequest)
    }
    
    private func loadMore() {
        let venueRequest = VenueRequest(skip: Int(nextImportOrdinal), limit: venuesPerCall)
        makeRequest(venueRequest)
    }
    
    func makeRequest(_ venueRequest:VenueRequest) {
        if loadingData {
            print("ERROR: Venue VM makeRequest: already loading data")
            return
        }
        ADPersistentContainer.shared.save()
        loadingData = true
        request(venueRequest) { result in
            switch result {
            case .success(let results):
                let nrVenuesLoaded = self.processApiResponse(response: results)
                
                DispatchQueue.main.async {
                    self.loadingData = false

                    ADPersistentContainer.shared.save()

                    if nrVenuesLoaded == self.venuesPerCall {
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

                //
                // Delete all venues
                //
                let fr: NSFetchRequest<NSFetchRequestResult> = Venue.fetchRequest()
                fr.includesPropertyValues = false
                if let existingVenues = try workMoc.fetch(fr) as? [Venue] {
                    for v in existingVenues {
                        workMoc.delete(v)
                    }
                }
            }
                  
            guard let categoryList = CategoryList(moc: workMoc) else {
                print("ERROR: Could not init CategoryList")
                return 0 // ToDo - error here?
            }
            
            let result = try decodeResponse(VenueSearchResponse.self, response: response, moc: workMoc)
            for venue in result.data {
                venue.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1
                
                guard let categoryStrings = venue.rawCategoryStrings else { continue }
                for c in categoryStrings {
                    venue.addToCategories(categoryList.category(named: c))
                    print("Added venue category: \(c)")
                }
            }
            
            try workMoc.save()
            return result.data.count
        } catch {
            print("ERROR in processApiResponse: \(error)")
            return 0
        }
    }
    
    func venue(at index: Int) -> Venue? {
        let indexPath = IndexPath(item: index, section: 0)
        return resultsController.object(at: indexPath)
    }
}

extension VenueViewModel: DataItemProvider {
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
    
    func item(at index: Int) -> DataItem? {
        return venue(at: index)
    }
}

