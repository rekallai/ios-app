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
    var interestTopics:[String]
    var favoriteVenueIds:[String]
    var email:String
    var firstName: String
    var lastName: String
    var createdAt:Date
    var updatedAt:Date
    var stripeCustomerId: String?
    var intercomUserHash: String?
    var optIns: OptIns?
    
    static func anonymous()->User {
        return User(id: "", roles: [], interestTopics: [], favoriteVenueIds: [], email: "", firstName: "", lastName: "", createdAt: Date(), updatedAt: Date(), stripeCustomerId: nil, intercomUserHash: nil, optIns: nil)
    }

    func isAdmin() -> Bool {
        return roles.contains("admin") || roles.contains("admin.read")
    }
}
