//
//  APIRequestTickets.swift
//  Rekall
//
//  Created by Ray Hunter on 30/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya


class APIRequestCurrentUserTickets: ADBaseRequest {
    
    override var path: String { return "/1/users/me/tickets" }
    override var method: Moya.Method { return .get }
    override var task: Task { return .requestPlain }
    override var authorizationType: AuthorizationType { return .bearer }
    
}


class APIResponseCurrentUserTickets: ADApiResponse {
    let data: [ResponseTicket]

    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([ResponseTicket].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
        
    struct ResponseTicket: Decodable {
        let id: String
        let orderId: String
        let paidAmountUsd: Int
        let issuedCode: String
        let status: String
        let createdAt: Date
        let updatedAt: Date
        let passkitAuthorizationToken: String
        let venue: Venue
        let ticketOption: TicketOption
    }
    
    struct TicketOption: Decodable {
        var date: String
        var name: String
        var price: Int
        var tax: Int
        var quantity: Int
        var venueId: String
    }
    
    struct Venue: Decodable {
        let id: String
        let images: [RawImage]
        let iosImages: [RawImage]
        let name: String
    }
}
