//
//  UIApplication+Extensions.swift
//  Rekall
//
//  Created by Steve on 8/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func call(phone: String) {
        if let encPhone = phone.addingPercentEncoding(withAllowedCharacters: CharacterSet()) {
            if let url = URL(string:"tel://\(encPhone)") {
                shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    static func mail(address: String) {
        if let url = URL(string: "mailto:\(address)") {
            shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
