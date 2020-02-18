//
//  Int+Prices.swift
//  Rekall
//
//  Created by Ray Hunter on 26/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension Int {
    public var dollarString: String {

        let dollars = self / 100
        let cents = self % 100
        
        return "$\(dollars).\(String(format: "%02d", cents))"
    }
}

extension Optional where Wrapped == Int {
    var dollarString: String {
        return self?.dollarString ?? "$0.00"
    }
}
