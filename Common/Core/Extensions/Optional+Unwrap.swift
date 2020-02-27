//
//  Optional+Unwrap.swift
//  Rekall
//
//  Created by Ray Hunter on 16/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension Optional {
    
    enum Errors: Error {
        case nilValue
    }
    
    func unwrapOrThrow() throws -> Wrapped {
        if let s = self { return s }
        throw Errors.nilValue
    }
}
