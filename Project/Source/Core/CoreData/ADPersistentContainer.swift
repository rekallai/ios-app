//
//  ADPersistentContainer.swift
//  Rekall
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreData

class ADPersistentContainer: NSPersistentContainer {
    
    override class func defaultDirectoryURL() -> URL {
        let baseUrl = super.defaultDirectoryURL()
        return baseUrl.appendingPathComponent("CoreData")
    }

    static private(set) var shared: ADPersistentContainer = openContainer()
    
    private class func openContainer() -> ADPersistentContainer {
        if Thread.isMainThread {
            return ADPersistentContainer()
        } else {
            var adpcOptional: ADPersistentContainer?
            DispatchQueue.main.sync {
                adpcOptional = ADPersistentContainer()
            }
            
            guard let adpc = adpcOptional else {
                fatalError("FATALERROR: failed to init ADPersistentContainer")
            }
            
            return adpc
        }
    }
    
    class func resetContainer() {
        for entity in shared.managedObjectModel.entities {
            guard let entityName = entity.name else { continue }
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let dr = NSBatchDeleteRequest(fetchRequest: fr)
            do {
                try shared.persistentStoreCoordinator.execute(dr, with: shared.viewContext)
            } catch {
                print("ERROR: Failed to delete objects: \(error)")
            }
        }
        
        shared.save()
    }
    
    private convenience init(){
        assert(Thread.isMainThread)
        
        self.init(name: "ADModel")
        loadPersistentStores { description, error in
            if let error = error {
                print("ERROR: Failed to load persistent stores: \(error)")
                Self.deletePersistentStores()
                self.loadPersistentStores { description, error in
                    if let error = error {
                        print("FATALERROR: Failed to load persistent stores a second time: \(error)")
                    }
                }
            }
        }
    }
    
    class func deletePersistentStores() {
        let url = defaultDirectoryURL()
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("ERROR: Failed to remove Core Data stores")
        }
    }
    
    func save() {
        assert(Thread.current == Thread.main)
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save MOC: \(error)")
        }
    }
    
    var childContext: NSManagedObjectContext {
        assert(!Thread.isMainThread)
        let child = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        child.parent = viewContext
        return child
    }
    
    
}
