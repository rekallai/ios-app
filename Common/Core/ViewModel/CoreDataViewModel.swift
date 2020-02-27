//
//  CoreDataViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 19/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import CoreData

protocol CoreDataViewModelDelegate: class {
    func didProcessModelUpdates(sender: CoreDataViewModel)
}

class CoreDataViewModel: ViewModel, NSFetchedResultsControllerDelegate {

    var dataSection: Int = 0
    weak var delegate: DataItemProviderDelegate?
    weak var coreDataModelDelegate: CoreDataViewModelDelegate?

    private var currentUpdateList: [DataItemUpdateRecord]?

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentUpdateList = [DataItemUpdateRecord]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let cud = currentUpdateList {
            delegate?.processBatchUpdates(updates: cud)
            coreDataModelDelegate?.didProcessModelUpdates(sender: self)
            currentUpdateList = nil
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let modifiedIndexPath = indexPath != nil ?
            IndexPath(item: indexPath!.item, section: dataSection) : nil
        let modifiedNewIndexPath = newIndexPath != nil ?
            IndexPath(item: newIndexPath!.item, section: dataSection) : nil
        
        switch type {
        case .insert:
            currentUpdateList?.append(DataItemUpdateRecord(.insert, modifiedIndexPath, modifiedNewIndexPath))
        case .delete:
            currentUpdateList?.append(DataItemUpdateRecord(.delete, modifiedIndexPath, modifiedNewIndexPath))
        case .move:
            currentUpdateList?.append(DataItemUpdateRecord(.move, modifiedIndexPath, modifiedNewIndexPath))
        case .update:
            currentUpdateList?.append(DataItemUpdateRecord(.update, modifiedIndexPath, modifiedNewIndexPath))
        @unknown default:
            print("ERROR: Unable to handle unknown default")
        }
    }    
}

