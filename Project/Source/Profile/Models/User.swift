//
//  User.swift
//  Rekall
//
//  Created by Steve on 6/26/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

struct User: Codable {
    var id:String
    var roles:[String]
    var email:String
    var firstName: String
    var lastName: String
    var createdAt:Date
    var updatedAt:Date
    
    static func anonymous()->User {
        return User(id: "", roles: [], email: "", firstName: "", lastName: "", createdAt: Date(), updatedAt: Date())
    }

    func isAdmin() -> Bool {
        return roles.contains("admin") || roles.contains("admin.read")
    }
}
