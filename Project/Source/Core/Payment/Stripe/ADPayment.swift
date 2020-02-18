//
//  ADPurchase.swift
//  Rekall
//
//  Created by Ray Hunter on 10/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

class ADPurchase {
    
    struct Item{
        let itemId: String
        let name: String
        let quantity: Int
        let priceUsd: Int
        
        func itemTotalPrice() -> Int {
            return quantity * priceUsd
        }
    }
    
    private(set) var items = [Item]()
    
    func addItem(item: Item){
        items.append(item)
    }
    
    func getTotalPrice() -> Int {
        var totalPrice = 0
        
        for i in items {
            let itemPrice = i.itemTotalPrice()
            totalPrice += itemPrice
        }
        
        return totalPrice
    }
    
    func getSummaryItems() -> [PKPaymentSummaryItem] {
        var summaryItems = [PKPaymentSummaryItem]()
        
        var totalPrice = 0
        
        for i in items {
            let itemPrice = i.itemTotalPrice()
            totalPrice += itemPrice
            let itemPriceString = "\(itemPrice / 100).\(itemPrice % 100)"
            summaryItems.append(PKPaymentSummaryItem.init(label: i.name,
                                                          amount: NSDecimalNumber(string: itemPriceString)))
        }
        
        let totalPriceString = "\(totalPrice / 100).\(totalPrice % 100)"
        summaryItems.append(PKPaymentSummaryItem.init(label: NSLocalizedString("Total", comment: "Checkout Total"), 
                                                      amount: NSDecimalNumber(string: totalPriceString)))

        return summaryItems
    }
    
    func getUserSummery() -> [(String, String)] {
        var summary = [(String, String)]()
        summary = items.map { item in return (item.name, item.itemTotalPrice().dollarString) }
        return summary
    }
}
