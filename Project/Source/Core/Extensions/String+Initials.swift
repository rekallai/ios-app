//
//  String+Initials.swift
//  Rekall
//
//  Created by Steve on 9/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension String {
    
    func initials()->String {
        let comps = components(separatedBy: " ")
        return comps.reduce("") {
            ($0 == "" ? "" : "\($0.first ?? "A")") + "\($1.first ?? "D")"
        }
    }
    
}
