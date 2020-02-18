//
//  InterestTopicsViewModel.swift
//  Rekall
//
//  Created by Steve on 6/24/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import CoreData

class InterestTopicViewModel: CoreDataViewModel {
    
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    private var nextImportOrdinal: Int32 = 0
    
    lazy private(set) var resultsController: NSFetchedResultsController<InterestTopic> = {
        let fr:NSFetchRequest<InterestTopic> = InterestTopic.fetchRequest()
        fr.sortDescriptors = [NSSortDescriptor(key: "importOrdinal", ascending: true)]
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
    
    func searchInterestTopics() {
        nextImportOrdinal = 0
        let interestTopicRequest = InterestTopicRequest()
        
        ADPersistentContainer.shared.save()
        request(interestTopicRequest) { result in
            switch result {
            case .success(let results):
                print("success with: \(results)")
                self.processApiResponse(response: results)
                
                DispatchQueue.main.async {
                    self.onUpdateSuccess?()
                }
            case .failure(let error):
                print("failure with: \(error)")
                DispatchQueue.main.async {
                    self.onUpdateFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processApiResponse(response: Moya.Response) {
        do {
            let workMoc = ADPersistentContainer.shared.childContext
            let fr: NSFetchRequest<NSFetchRequestResult> = InterestTopic.fetchRequest()
            fr.includesPropertyValues = false
            if let existingInterestTopics = try workMoc.fetch(fr) as? [InterestTopic] {
                for it in existingInterestTopics {
                    workMoc.delete(it)
                }
            }
            
            let result = try decodeResponse(InterestTopicSearchResponse.self, response: response, moc: workMoc)
            for interestTopic in result.data {
                interestTopic.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1
            }
            
            try workMoc.save()
        } catch {
            print("Error processing interest topic api response: \(error)")
        }
    }
    
    func interestTopic(at index:Int)-> InterestTopic {
        let indexPath = IndexPath(item: index, section:0)
        return resultsController.object(at: indexPath)
    }
}

extension InterestTopicViewModel: DataItemProvider {
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }

    func item(at index: Int) -> DataItem? {
        return interestTopic(at: index) as? DataItem
    }
}
