//
//  Category+Icon.swift
//  Rekall
//
//  Created by Steve on 10/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension Category {
    
    func icon()->UIImage? {
        if let name = name?.replacingOccurrences(of: " ", with: "") {
            let fullName = "Directory/\(name)"
            if let img = UIImage(named: fullName) {
                return img
            }
        }
        return nil
    }
    
}
