//
//  CoreDataContext+CoreDataClass.swift
//  Rekall
//
//  Created by Ray Hunter on 26/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//
//

import Foundation
import CoreData

@objc
public class CoreDataContext: NSManagedObject {
    
    static private(set) var shared: CoreDataContext = getCoreDataContext()
    
    private class func getCoreDataContext() -> CoreDataContext {
        assert(Thread.current == Thread.main)
        let fr: NSFetchRequest<CoreDataContext> = CoreDataContext.fetchRequest()
        
        do {
            let results = try ADPersistentContainer.shared.viewContext.fetch(fr)
            if results.count == 1 {
                return results[0]
            }
        } catch {
            print("CoreDataContext: shared: error: \(error)")
        }
        
        return CoreDataContext(context: ADPersistentContainer.shared.viewContext)
    }
    
    class func resetCoreDataContext() {
        shared = getCoreDataContext()
    }
    
    func venuesUpdated() {
        self.lastDataUpdate = Date()
    }
    
    func venuesNeedUpdated() -> Bool {
        guard let lastUpdate = lastDataUpdate else {
            return true
        }
        
        return Date().timeIntervalSince(lastUpdate) > 60 * 15
    }
    
}
