//
//  CategoryViewModel.swift
//  Rekall
//
//  Created by Steve on 8/5/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import CoreData

struct CategorySection {
    var title:String
    var categories:[Category]
}

class CategoryViewModel: CoreDataViewModel {
    
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    private var nextImportOrdinal: Int32 = 0
    
    var categorySections = [CategorySection]()
    
    func setCategorySections() {
        if let all = resultsController.fetchedObjects {
            let grouped = Dictionary(
                grouping: all, by: { $0.categoryType }
            )
            let sections = grouped.map { key, value in
                return CategorySection(
                    title: key ?? "",
                    categories: value
                )
            }
            categorySections = sections.sorted(by: { (first, second) -> Bool in
                //make sure "Services" is last to match design
                if first.title == "Services" {
                    return false
                } else if second.title == "Services" {
                    return true
                } else {
                    return first.title < second.title
                }
            })
        }
    }
    
    lazy private(set) var resultsController: NSFetchedResultsController<Category> = {
        let fr:NSFetchRequest<Category> = Category.fetchRequest()
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
    
    func loadCategories() {
        nextImportOrdinal = 0
        let categoriesRequest = CategoryRequest()
        
        ADPersistentContainer.shared.save()
        request(categoriesRequest) { result in
            switch result {
            case .success(let results):
                self.processApiResponse(response: results)
                self.setCategorySections()
                DispatchQueue.main.async {
                    self.onUpdateSuccess?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onUpdateFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processApiResponse(response: Moya.Response) {
        do {
            let workMoc = ADPersistentContainer.shared.childContext
            let fr: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
            fr.includesPropertyValues = false
            if let existingCategories = try workMoc.fetch(fr) as? [Category] {
                for it in existingCategories {
                    workMoc.delete(it)
                }
            }
            
           let result = try decodeResponse(
                CategoryResponse.self, response: response, moc: workMoc
            )
            
            for category in result.data {
                category.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1
            }
            
            try workMoc.save()
        } catch {
            print("Error processing categories api response")
        }
    }
    
}

extension CategoryViewModel {
    
    func numberOfSections()->Int {
        return categorySections.count
    }
    
    func numberOfItems(section:Int)->Int {
        return categorySections[section].categories.count
    }
    
    func section(at indexPath:IndexPath)->CategorySection {
        return categorySections[indexPath.section]
    }
    
    func category(at indexPath:IndexPath)->Category {
        return categorySections[indexPath.section].categories[indexPath.row]
    }
}
