//
//  TicketOptionCell.swift
//  Rekall
//
//  Created by Steve on 7/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol TicketStepperCellDelegate: class {
    func ticketStepperChanged(value: Int,cell: TicketStepperCell)
}

class TicketStepperCell: UITableViewCell {

    weak var delegate: TicketStepperCellDelegate?
    
    static let identifier = "TicketOptionCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet var ticketNameLabel: UILabel!
    @IBOutlet var ticketPriceLabel: UILabel!
    @IBOutlet var guestCountLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var ticketsRemainingLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper?
    
    var ticketInventoryItem: TicketInventoryItem? {
        didSet {
            ticketNameLabel.text = ticketInventoryItem?.name
            ticketPriceLabel.text = ticketInventoryItem?.price.dollarString
            
            let quantity = ticketInventoryItem?.orderQuantity ?? 0
            stepper?.value = Double(quantity)
            
            if ticketInventoryItem?.bundled == true {
                stepper?.maximumValue = 100000.0
            } else {
                stepper?.maximumValue = Double(ticketInventoryItem?.quantity ?? 0)
            }

            configureUiForOrderWith(quantity: quantity)
        }
    }

    @IBAction func stepperChanged(_ sender: Any) {
        if let value = stepper?.value {
            
            let orderQuantity = Int(value)
            ticketInventoryItem?.orderQuantity = orderQuantity

            configureUiForOrderWith(quantity: orderQuantity)

            delegate?.ticketStepperChanged(value: orderQuantity, cell: self)
        }
    }
    
    private func configureUiForOrderWith(quantity: Int) {
        guestCountLabel.isHidden = quantity == 0
        guestCountLabel?.text = quantity == 1 ?
            NSLocalizedString("\(quantity) Guest", comment: "Ticket amount label") :
            NSLocalizedString("\(quantity) Guests", comment: "Ticket amount label")
        
        totalPriceLabel.isHidden = quantity == 0
        
        let totalPrice = (ticketInventoryItem?.price ?? 0) * quantity
        totalPriceLabel.text = totalPrice.dollarString
        
        guard let value = stepper?.value else {
            return
        }
        
        let orderQuantity = Int(value)
        let quantityLeft = (ticketInventoryItem?.quantity ?? 0) - orderQuantity
        
        if quantityLeft > 0 && quantityLeft < 10 {
            ticketsRemainingLabel.isHidden = false
            if quantityLeft == 1 {
                ticketsRemainingLabel.text = NSLocalizedString("Only 1 ticket remaining",
                                                               comment: "Tickets available lavel")
            } else {
                ticketsRemainingLabel.text = NSLocalizedString("Only \(quantityLeft) tickets remaining",
                                                               comment: "Tickets available lavel")
            }
        } else {
            ticketsRemainingLabel.isHidden = true
        }
        
        if quantityLeft == 0 {
            ticketPriceLabel.text = NSLocalizedString("Sold out", comment: "No tickets left label")
            ticketPriceLabel.textColor = UIColor.red
        } else {
            ticketPriceLabel.text = ticketInventoryItem?.price.dollarString
            ticketPriceLabel.textColor = UIColor(named: "LabelSubtitleText")
        }
    }
}
