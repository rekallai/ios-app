//
//  TicketOption.swift
//  Rekall
//
//  Created by Steve on 7/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

class TicketInventoryItem: Decodable {
    let name: String
    let ticketOptionId: String
    let externalId: String
    let date: Date
    let quantity: Int
    let status: String
    let price: Int
    let tax: Int
    let fee: Int
    let currency: String
    let bundled: Bool
    
    // How many the user wants to buy in this session
    var orderQuantity: Int? = 0
    
    func itemPriceIncludingTax() -> Int {
        return price + tax
    }
}
