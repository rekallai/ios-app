//
//  ProductView.swift
//  ProjectTV
//
//  Created by Ray Hunter on 26/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI

struct ProductView: View {
    
    var product: Product

    var body: some View {
        Text(product.name ?? "Unknown")
    }
}
