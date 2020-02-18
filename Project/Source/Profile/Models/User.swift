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
    
    mutating func updateInterest(_ topicName:String) {
        if interestTopics.contains(topicName) {
            self.interestTopics.removeAll { (interest) -> Bool in
                interest == topicName
            }
        } else {
            interestTopics.append(topicName)
        }
    }
    
    func isInterested(_ interestName:String)->Bool {
        return interestTopics.contains(interestName)
    }
    
    mutating func updateFavorite(_ venueId:String) {
        if favoriteVenueIds.contains(venueId) {
            self.favoriteVenueIds.removeAll { (vid) -> Bool in
                vid == venueId
            }
        } else {
            favoriteVenueIds.append(venueId)
        }
    }
    
    func isFavorited(_ venueId:String)->Bool {
        return favoriteVenueIds.contains(venueId)
    }

    func isAdmin() -> Bool {
        return roles.contains("admin") || roles.contains("admin.read")
    }
}
