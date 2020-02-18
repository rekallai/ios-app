//
//  UILabel+Instantiate.swift
//  Rekall
//
//  Created by Steve on 7/22/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UILabel {
    
    static func create(_ text:String, isSemi:Bool)->UILabel {
        let weight:UIFont.Weight = isSemi ? .semibold : .regular
        let newLabel = UILabel()
        newLabel.text = text
        newLabel.font = UIFont.systemFont(
            ofSize: 14.0, weight:weight
        )
        newLabel.numberOfLines = 0
        return newLabel
    }
    
}
