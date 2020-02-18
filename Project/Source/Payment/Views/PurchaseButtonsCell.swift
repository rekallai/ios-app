//
//  PurchaseButtonsCell.swift
//  Rekall
//
//  Created by Ray Hunter on 29/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

class PurchaseButtonsCell: UITableViewCell {

    var payButtonDelegate: PayButtonDelegate? {
        didSet {
            payButton.delegate = payButtonDelegate
        }
    }
    
    @IBOutlet var buttonStackView: UIStackView!
    @IBOutlet var checkoutButton: BorderButton!
    var payButton = PayButton()
    var applePayButton: PKPaymentButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            applePayButton = payButton.create()
        }
    }
    
    func configureAs(initialCheckout: Bool) {
        if initialCheckout {
            
            checkoutButton.setTitle(NSLocalizedString("Check Out", comment: "Button Title"),
                                    for: .normal)
            
            if let applePayButton = applePayButton {
                buttonStackView.insertArrangedSubview(applePayButton, at: 0)
            }
        } else {
            checkoutButton.setTitle(NSLocalizedString("Confirm Tickets", comment: "Button Title"),
                                    for: .normal)
            
            applePayButton?.removeFromSuperview()
        }
    }
    
    func setStateEnabled(_ enabled: Bool) {
        applePayButton?.isEnabled = enabled
        applePayButton?.alpha = enabled ? 1.0 : 0.5
        checkoutButton.isEnabled = enabled
        checkoutButton.alpha = enabled ? 1.0 : 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
