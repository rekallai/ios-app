//
//  AD+CodingUserInfoKey.swift
//  Rekall
//
//  Created by Ray Hunter on 06/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
