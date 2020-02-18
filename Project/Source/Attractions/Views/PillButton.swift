//
//  PillButton.swift
//  Rekall
//
//  Created by Steve on 7/8/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PillButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = bounds.height / 2.0
    }
    
}
