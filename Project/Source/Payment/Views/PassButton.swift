//
//  PassButton.swift
//  Rekall
//
//  Created by Steve on 7/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

protocol PassButtonDelegate: class {
    func passButtonTapped()
}

class PassButton {
    weak var delegate: PassButtonDelegate?

    func create()->PKAddPassButton {
        let passButton = PKAddPassButton(
            addPassButtonStyle: .black
        )
        passButton.addTarget(
            self,
            action: #selector(passButtonTapped),
            for:.touchUpInside
        )
        passButton.translatesAutoresizingMaskIntoConstraints = false
        passButton.heightAnchor.constraint(
            equalToConstant: 44.0
        ).isActive = true
        return passButton
    }
    
    @objc func passButtonTapped() {
        delegate?.passButtonTapped()
    }
}
