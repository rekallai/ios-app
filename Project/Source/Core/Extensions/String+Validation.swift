//
//  String+Validation.swift
//  Rekall
//
//  Created by Ray Hunter on 23/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension String {
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
