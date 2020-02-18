//
//  UIImageView+Color.swift
//  Rekall
//
//  Created by Steve on 11/26/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setColor(_ color: UIColor) {
        let temp = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = temp
        self.tintColor = color
    }
    
}
