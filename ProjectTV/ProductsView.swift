//
//  ProductsView.swift
//  ProjectTV
//
//  Created by Ray Hunter on 26/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI
import CoreData

struct ProductsView: View {
    
    var shop: Shop
    
    @State var productsViewModel = ProductsViewModel(api: BRApi.shared.api, store: BRApi.shared.store)

    var body: some View {
        NavigationView {
            ScrollView(.horizontal) {
                HStack {
                    ForEach (productsViewModel, id: \.id) { product in
                        NavigationLink(destination: ProductFullscreenView(productName: product.name ?? "Unknown")) {
                            ProductView(product: product)
                        }
                    }
                }
            }
        }.onAppear() {
            if let shopId = self.shop.id {
                self.productsViewModel.shopId = shopId
                
                self.productsViewModel.onUpdateSuccess = {
                    print("Products success")
                }

                self.productsViewModel.onUpdateFailure = { errorStr in
                    print("Products failure")
                }

                self.productsViewModel.loadProducts()
            }
        }
    }

}
