//
//  Store+Selectors.swift
//  Snoutscan
//
//  Created by Levi McCallum on 4/9/19.
//  Copyright © 2019 Rekall. All rights reserved.
//

import Foundation

extension Store {
    var isAuthenticated: Bool {
        return state.token != nil
    }
}
