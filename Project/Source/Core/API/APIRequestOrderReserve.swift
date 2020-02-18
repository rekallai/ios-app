//
//  APIRequestOrder.swift
//  Rekall
//
//  Created by Steve on 7/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class APIRequestOrderReserve: ADBaseRequest {
    
    struct TicketOrderOption: Codable {
        let ticketOptionId: String
        let quantity: Int
        let reservationDate: String
    }
    
    var items: [TicketOrderOption]
    var paymentToken: String
    var saveCardDetails: Bool
    
    init(items: [TicketOrderOption], paymentToken: String, saveCardDetails: Bool) {
        self.items = items
        self.paymentToken = paymentToken
        self.saveCardDetails = saveCardDetails
    }

    private struct Order: Codable {
        let items: [TicketOrderOption]
        let paymentToken: String
        let saveCard: Bool
    }
    
    private struct OrderWithoutSavedCard: Codable {
        let items: [TicketOrderOption]
        let paymentToken: String?
    }

    override var path: String { return "/1/orders" }
    override var method: Moya.Method { return .post }
    override var task: Task {
        let order: Encodable = saveCardDetails ? Order(items: items, paymentToken: paymentToken, saveCard: true) :
                                                 OrderWithoutSavedCard(items: items, paymentToken: paymentToken)
        return .requestJSONEncodable(order)
    }
    override var authorizationType: AuthorizationType { return .bearer }
}


class APIResponseOrderReserve: ADApiResponse {
    let data: OrderReservation
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        data = try container.decode(OrderReservation.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}


struct OrderReservation: Decodable {
    var order: ConfirmedOrder
    var intent: Intent?
    
    struct Intent: Decodable {
        var id: String
        var amount: Int
        var client_secret: String
        var confirmation_method: String
        var currency: String
        var status: String
    }
}
