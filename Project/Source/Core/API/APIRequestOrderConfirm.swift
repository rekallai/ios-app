//
//  APIRequestOrder.swift
//  Rekall
//
//  Created by Steve on 7/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class APIRequestOrderConfirm: ADBaseRequest {
    
    let orderId: String
    let paymentIntentId: String
    let saveCard: Bool

    init(orderId: String, paymentIntentId: String, saveCard: Bool){
        self.orderId = orderId
        self.paymentIntentId = paymentIntentId
        self.saveCard = saveCard
    }

    private struct OrderConfirm: Codable {
        let orderId: String
        let paymentIntentId: String
        let saveCard: Bool
    }

    override var path: String { return "/1/orders/confirm" }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(OrderConfirm(orderId: orderId,
                                                  paymentIntentId: paymentIntentId,
                                                  saveCard: saveCard))
    }
    override var authorizationType: AuthorizationType { return .bearer }
}


class APIResponseOrderConfirm: ADApiResponse {
    let data: OrderConfirmResponse
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        data = try container.decode(OrderConfirmResponse.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
    
    struct OrderConfirmResponse: Decodable {
        let order: ConfirmedOrder
    }
}


struct ConfirmedOrder: Decodable {
    var id: String
    var paymentToken: String
    var createdAt: String
    var updatedAt: String
    var status: String
    var totalAmount: Int
    
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
        var ticketOption: TicketOption
    }
    
    struct TicketOption: Decodable {
        var date: String
        var name: String
        var price: Int
        var tax: Int
        var quantity: Int
        var venueId: String
    }
    
    struct Item: Decodable {
        var venueId: String
        var ticketOptionId: String
        var quantity: Int
        var totalAmount: Int
        var date: String
    }
}
