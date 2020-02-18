//
//  NSMutableAttributedString+Color.swift
//  Rekall
//
//  Created by Steve on 10/31/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    func set(color: UIColor, on text: String) {
        let range = mutableString.range(of: text, options: .caseInsensitive)
        if range.length > 0 {
            addAttribute(.foregroundColor, value: color, range: range)
        }
    }
    
    func setTextBlackWhite() {
        let allRange = NSRange(location: 0, length: length)
        let allColor = UIColor(named: "BlackWhite")!
        addAttribute(.foregroundColor, value: allColor, range: allRange)
    }
    
}
