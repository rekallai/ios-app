//
//  FillButton.swift
//  Rekall
//
//  Created by Steve on 6/18/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class FillButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(named: "ButtonBackground")
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 8.0
    }
    
}
