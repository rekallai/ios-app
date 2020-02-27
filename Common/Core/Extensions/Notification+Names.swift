//
//  Notification+Names.swift
//  Rekall
//
//  Created by Ray Hunter on 24/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension Notification {
    public static let apiTokenExpired = Notification.Name("apiTokenExpired")
    public static let userLoggedIn = Notification.Name("userLoggedIn")
}
