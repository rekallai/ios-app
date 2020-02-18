//
//  Order.swift
//  Rekall
//
//  Created by Steve on 7/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

struct Order: Decodable {
    var id:String
    //var userId:String
    var paymentToken:String
    var createdAt:String
    var updatedAt:String
    var status:String
    
    let tickets: [Ticket]
    let items: [Item]
    
    struct Ticket: Decodable {
        var createdAt: Date
        var id: String
        var issuedCode: String
        var orderId: String
        var paidAmountUsd: Double
        var sharedWithEmails: [String]
        var sharedWithUserIds: [String]
        var status: String
        var updatedAt: Date
        //var userId: String
        //var venueId: String
        var passkitAuthorizationToken: String
    }
    
    struct Item: Decodable {
        var venueId: String
        var ticketOptionId: String
        var quantity: Int
        var amount: Int
    }
}
