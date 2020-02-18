//
//  RoundedImageView.swift
//  Rekall
//
//  Created by Steve on 7/8/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class RoundedImageView: ProxyImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
    }

}
