//
//  PaymentTotalCell.swift
//  Rekall
//
//  Created by Ray Hunter on 25/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PaymentTotalCell: UITableViewCell {

    static let identifier = "PaymentTotalCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet var ticketSubtotalLabel: UILabel!
    @IBOutlet var ticketSubtotalPriceLabel: UILabel!
    @IBOutlet var taxesPriceLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    
    var priceCalulator: TicketPriceCalculator?{
        didSet {
            updateLabels()
        }
    }
    
    func updateLabels() {
        guard let priceCalulator = priceCalulator else { return }
        ticketSubtotalLabel.text = NSLocalizedString("Ticket Subtotal: (\(priceCalulator.totalTickets))",
                                                     comment: "Total number of tickets being bought")
        ticketSubtotalPriceLabel.text = priceCalulator.subTotal.dollarString
        taxesPriceLabel.text = priceCalulator.taxCost.dollarString
        totalLabel.text = priceCalulator.total.dollarString
    }
}
