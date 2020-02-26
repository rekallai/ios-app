//
//  ProductsViewModel.swift
//  Project
//
//  Created by Ray Hunter on 20/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import CoreData


class ProductsViewModel: CoreDataViewModel {
    
    var shopId: String = ""
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
    
    lazy private(set) var resultsController: NSFetchedResultsController<Product> = {
        let fr: NSFetchRequest<Product> = Product.fetchRequest()
        fr.sortDescriptors = sortDescriptors
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: BRPersistentContainer.shared.viewContext,
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
    
    func loadProducts() {
        if loadingData {
            print("ERROR: Product VM loadProducts: already loading data")
            return
        }

        nextImportOrdinal = 0
        let productRequest = ProductRequest(shopId: shopId, skip: Int(nextImportOrdinal), limit: dataItemsPerCall)
        makeRequest(productRequest)
    }
    
    private func loadMore() {
        let productRequest = ProductRequest(shopId: shopId, skip: Int(nextImportOrdinal), limit: dataItemsPerCall)
        makeRequest(productRequest)
    }
    
    func makeRequest(_ productRequest:ProductRequest) {
        if loadingData {
            print("ERROR: Product VM makeRequest: already loading data")
            return
        }
        BRPersistentContainer.shared.save()
        loadingData = true
        request(productRequest) { result in
            switch result {
            case .success(let results):
                let nrProductsLoaded = self.processApiResponse(response: results)
                
                DispatchQueue.main.async {
                    self.loadingData = false

                    BRPersistentContainer.shared.save()

                    if nrProductsLoaded == self.dataItemsPerCall {
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
            let workMoc = BRPersistentContainer.shared.childContext
            
            if nextImportOrdinal == 0 {

                //
                // Delete all products
                //
                let fr: NSFetchRequest<NSFetchRequestResult> = Product.fetchRequest()
                fr.includesPropertyValues = false
                if let existingProducts = try workMoc.fetch(fr) as? [Product] {
                    for v in existingProducts {
                        workMoc.delete(v)
                    }
                }
            }
                              
            let result = try decodeResponse(ProductSearchResponse.self, response: response, moc: workMoc)
            for product in result.data {
                product.importOrdinal = nextImportOrdinal
                nextImportOrdinal += 1
            }
            
            try workMoc.save()
            return result.data.count
        } catch {
            print("ERROR in processApiResponse: \(error)")
            return 0
        }
    }
    
    func product(at index: Int) -> Product? {
        let indexPath = IndexPath(item: index, section: 0)
        return resultsController.object(at: indexPath)
    }
    
    var numberOfItems: Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
}


extension ProductsViewModel: RandomAccessCollection {
    var startIndex: Int {
        0
    }
    
    var endIndex: Int {
        numberOfItems
    }
    
    subscript(position: Int) -> Product {
        return product(at: position)!
    }
        
    typealias Element = Product
    typealias Index = Int
    typealias SubSequence = Slice<ProductsViewModel>
    typealias Indices = Range<Int>
}
