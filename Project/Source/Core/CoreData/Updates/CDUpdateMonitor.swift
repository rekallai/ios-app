//
//  CDUpdateMonitor.swift
//  Rekall
//
//  Created by Ray Hunter on 25/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreData

protocol CDUpdatable: NSManagedObject {
    
    /// Return a block that identifies equivalent objects. One should be able to replace the other
    func equivalentObjectComparator() -> ((Self) -> Bool)
}

///
///  Monitor that automatically replaces CDUpdatable items as they are updated or replaced
///
class CDUpdateMonitor<T : CDUpdatable>: NSObject {

    private var objectComparator: ((T) -> Bool)
    private (set) var cdItem: T?
    private var updateBlock: (() -> ())?
    
    init(cdItem: T, updateBlock: (() -> ())? = nil) {
        self.cdItem = cdItem
        self.updateBlock = updateBlock
        objectComparator = cdItem.equivalentObjectComparator()
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updated),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: cdItem.managedObjectContext)
    }
    
    @objc func updated(_ notification: Notification){
        var modified = false

        if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<T> {
            for u in updated {
                if objectComparator(u) {
                    self.cdItem = u
                    modified = true
                }
            }
        }
        
        if let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<T> {
            for d in deleted {
                if objectComparator(d) {
                    self.cdItem = nil
                    modified = true
                }
            }
        }

        if let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<T> {
            for i in inserted {
                if objectComparator(i) {
                    self.cdItem = i
                    modified = true
                }
            }
        }
        
        if modified {
            updateBlock?()
        }
    }
}
