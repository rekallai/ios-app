//
//  BorderButton.swift
//  Rekall
//
//  Created by Steve on 6/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class BorderButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        let blue = UIColor(named: "ButtonBackground")
        backgroundColor = UIColor(named: "WhiteBlack")
        layer.borderColor = blue!.cgColor
        layer.borderWidth = 1.0
        setTitleColor(blue, for: .normal)
        layer.cornerRadius = 8.0
    }
    
}
