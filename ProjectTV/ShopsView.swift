//
//  ContentView.swift
//  ProjectTV
//
//  Created by Ray Hunter on 21/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct ShopsView: View {
    @State private var selection = 0
    
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "Shop", in: BRPersistentContainer.shared.viewContext)!,
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Shop.importOrdinal, ascending: true)
        ]
    ) var shops: FetchedResults<Shop>
    
    
    private let shopVm = ShopViewModel(api: BRApi.shared.api, store: BRApi.shared.store)

    init() {
        shopVm.onUpdateSuccess = {
            print("success")
        }
        shopVm.onUpdateFailure = { error in
            print("failure: \(error)")
        }
        
        // ToDo - remove test token, add auth
        BRApi.shared.store.storeToken(newToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1ZTRlYWVjMTU2Y2JmMTFiZDQ5YTgyYzQiLCJ0eXBlIjoidXNlciIsImtpZCI6InVzZXIiLCJpYXQiOjE1ODI1NjMwNDUsImV4cCI6MTU4NTE1NTA0NX0.0w17bcUVizQi_TI8gRXxeKtT4mINozrnjEUeL1q63Lc")
        shopVm.loadShops()
    }
    
    @Environment(\.managedObjectContext) var moc
 
    //var model = AppEnvironment.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(shops, id: \.id) { shop in
                    NavigationLink(destination: ProductsView(shop: shop)) {
                        ShopView(shop: shop)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShopsView()
    }
}
