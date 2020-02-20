//
//  ShopViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

import UIKit
import Moya
import CoreData

class ShopViewModel: CoreDataViewModel {
    
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
        
    func updateResultsControllerWith(predicate: NSPredicate?){
        resultsController.fetchRequest.predicate = predicate
        
        do {
            try resultsController.performFetch()
        } catch {
            print("ERROR: performFetch() failed")
        }
    }
    
    var sortDescriptors = [NSSortDescriptor(key: "importOrdinal", ascending: true)]
    
    private var nextImportOrdinal: Int32 = 0
    
    lazy private(set) var resultsController: NSFetchedResultsController<Shop> = {
        let fr: NSFetchRequest<Shop> = Shop.fetchRequest()
        fr.sortDescriptors = sortDescriptors
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
    private let dataItemsPerCall = 50
    
    func loadVenues() {
        if loadingData {
            print("ERROR: Shop VM loadVenues: already loading data")
            return
        }

        nextImportOrdinal = 0
        let venueRequest = ShopRequest(skip: Int(nextImportOrdinal), limit: dataItemsPerCall)
        makeRequest(venueRequest)
    }
    
    private func loadMore() {
        let venueRequest = ShopRequest(skip: Int(nextImportOrdinal), limit: dataItemsPerCall)
        makeRequest(venueRequest)
    }
    
    func makeRequest(_ venueRequest:ShopRequest) {
        if loadingData {
            print("ERROR: Shop VM makeRequest: already loading data")
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

                    if nrVenuesLoaded == self.dataItemsPerCall {
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
                let fr: NSFetchRequest<NSFetchRequestResult> = Shop.fetchRequest()
                fr.includesPropertyValues = false
                if let existingVenues = try workMoc.fetch(fr) as? [Shop] {
                    for v in existingVenues {
                        workMoc.delete(v)
                    }
                }
            }
                              
            let result = try decodeResponse(ShopSearchResponse.self, response: response, moc: workMoc)
            for venue in result.data {
                venue.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1                
            }
            
            try workMoc.save()
            return result.data.count
        } catch {
            print("ERROR in processApiResponse: \(error)")
            return 0
        }
    }
    
    func shop(at index: Int) -> Shop? {
        let indexPath = IndexPath(item: index, section: 0)
        return resultsController.object(at: indexPath)
    }
    
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
}

