//
//  ShopView.swift
//  ProjectTV
//
//  Created by Ray Hunter on 24/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI

struct ShopView: View {
    
    @State var shop: Shop
    
    @Environment(\.imageFetcher) var imageFetcher
    static let defaultImageUrl = URL(string: "https://i0.wp.com/cdn-prod.medicalnewstoday.com/content/images/articles/270/270202/cups-of-coffee.jpg?w=1155&h=1541")!
    
    var body: some View {
        VStack {
            AsyncImage(source: imageFetcher.image(for: shop.imageUrls?.first ?? Self.defaultImageUrl), placeholder: UIImage())
            Text(shop.name ?? "Unknown")
        }.frame(width: 300.0 * 16.0 / 9.0, height: 300.0)
    }    
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopsView()
    }
}

