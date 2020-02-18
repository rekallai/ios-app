//
//  DataItemProvider.swift
//  Rekall
//
//  Created by Ray Hunter on 18/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol DataItem {
    var name: String? {get}
    var imageUrls: [URL]? {get}
    var itemDescription: String? {get}
    var itemShortDescription: String? {get}
    var itemTag: String? {get}
}

protocol DataItemProvider {
    var numberOfItems: Int {get}
    func item(at index: Int) -> DataItem?
    var delegate: DataItemProviderDelegate? {get set}
}

typealias DataItemUpdateRecord = (DataItemUpdateType, IndexPath?, IndexPath?)

protocol DataItemProviderDelegate: class {
    func processBatchUpdates(updates: [DataItemUpdateRecord])
}

enum DataItemUpdateType {
    case insert
    case delete
    case move
    case update
}

//
//  Allow any class that has a collection view to update based on DataItemProvider changes
//
protocol CollectionViewCoreDataItemUpdate: DataItemProviderDelegate{
    var collectionView: UICollectionView? {get}
}

extension CollectionViewCoreDataItemUpdate {
    func processBatchUpdates(updates: [DataItemUpdateRecord]) {
        
        guard let cv = collectionView else {
            return
        }
        
        cv.performBatchUpdates({
            for (type, indexPath, newIndexPath) in updates {
                switch type
                {
                case .insert:
                    cv.insertItems(at: [newIndexPath!])
                case .delete:
                    cv.deleteItems(at: [indexPath!])
                case .update:
                    cv.reloadItems(at: [indexPath!])
                case .move:
                    cv.moveItem(at: indexPath!, to: newIndexPath!)
                }
            }
        }, completion: nil)
    }
}


//
//  Allow any class that has a table view to update based on DataItemProvider changes
//
protocol TableViewCoreDataItemUpdate: DataItemProviderDelegate{
    var tableView: UITableView? {get}
}

extension TableViewCoreDataItemUpdate {
    func processBatchUpdates(updates: [DataItemUpdateRecord]) {
        
        guard let tv = tableView else {
            return
        }
        
        tv.performBatchUpdates({
            for (type, indexPath, newIndexPath) in updates {
                switch type
                {
                case .insert:
                    tv.insertRows(at: [newIndexPath!], with: .fade)
                case .delete:
                    tv.deleteRows(at: [indexPath!], with: .fade)
                case .update:
                    tv.reloadRows(at: [indexPath!], with: .fade)
                case .move:
                    tv.moveRow(at: indexPath!, to: newIndexPath!)
                }
            }
        }, completion: nil)
    }
}
