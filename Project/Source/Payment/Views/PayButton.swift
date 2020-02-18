//
//  ApplePayButton.swift
//  Rekall
//
//  Created by Steve on 7/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

protocol PayButtonDelegate: class {
    func payButtonTapped()
}

class PayButton {
    weak var delegate: PayButtonDelegate?
    
    func create()->PKPaymentButton {
        let payButton = PKPaymentButton(
            paymentButtonType: .buy, paymentButtonStyle: .black
        )
        payButton.addTarget(
            self,
            action: #selector(payButtonTapped),
            for:.touchUpInside
        )
        if #available(iOS 12.0, *) {
            payButton.cornerRadius = 8.0
        }
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        return payButton
    }
    
    @objc func payButtonTapped() {
        delegate?.payButtonTapped()
    }
    
}
