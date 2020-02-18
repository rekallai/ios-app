//
//  TicketOption.swift
//  Rekall
//
//  Created by Steve on 7/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

class TicketOption: Decodable {
    var id:String
    var name:String
    //var userId:String
    var priceUsd:Int
    var createdAt:Date
    var updatedAt:Date
}
