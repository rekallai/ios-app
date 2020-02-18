//
//  TicketCalculator.swift
//  Rekall
//
//  Created by Steve on 7/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

struct TicketQuantity {
    var inventoryItem: TicketInventoryItem
    var quantity: Int
}

class TicketPriceCalculator {
    var ticketQuantity = [TicketQuantity]()
    var total = 0
    var subTotal = 0
    var taxCost = 0
    var totalTickets = 0
    
    func setTickets(tickets:[TicketInventoryItem]) {
        ticketQuantity = tickets.enumerated().map { (index,value) in
            return TicketQuantity(inventoryItem: value, quantity: 0)
        }
        calculate()
    }
    
    func update(quantity:Int, at:Int) {
        ticketQuantity[at].quantity = quantity
        calculate()
    }
    
    private func calculate() {
        subTotal = 0
        totalTickets = 0
        var totalTax = 0
        ticketQuantity.forEach { (ticketQuantity) in
            let price = ticketQuantity.inventoryItem.price
            let thisTicketPrice = (price * ticketQuantity.quantity)
            let thisTicketTaxPrice = ticketQuantity.inventoryItem.tax * ticketQuantity.quantity
            subTotal += thisTicketPrice
            totalTax += thisTicketTaxPrice
            totalTickets += ticketQuantity.quantity
        }
        taxCost = totalTax
        total = subTotal + totalTax
    }
    
    private func rounded(_ value:Double)->Double {
        let divisor = pow(10.0, 2.0)
        return (value * divisor).rounded()/divisor
    }
    
}
