//
//  CategoryList.swift
//  Rekall
//
//  Created by Ray Hunter on 25/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreData

// Venue Category List
class CategoryList: NSObject {

    private typealias VenueCategoryList = [String: VenueCategory]
    private var list: VenueCategoryList
    private let moc: NSManagedObjectContext

    init?(moc: NSManagedObjectContext) {
        self.moc = moc
        
        do {
            let fr: NSFetchRequest<VenueCategory> = VenueCategory.fetchRequest()
            let results = try moc.fetch(fr)
            
            list = VenueCategoryList()
            for vc in results {
                guard let name = vc.name else { continue }
                list[name] = vc
            }
        } catch {
            print("ERROR: Failed to load venue category list")
            return nil
        }
    }
    
    func category(named: String) -> VenueCategory {
        if let category =  list[named] {
            return category
        }
        
        let vc = VenueCategory(context: moc)
        vc.name = named
        list[named] = vc
        return vc
    }
}
