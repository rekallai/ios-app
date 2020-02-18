//
//  APIRequestTicketInventory.swift
//  Rekall
//
//  Created by Ray Hunter on 24/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class APIRequestTicketInventory: ADBaseRequest {
    var venueId: String
    var date: String
    
    init(venueId: String, date: Date) {
        self.venueId = venueId
        self.date = DateFormatter.yearMonthDayGmt.string(from: date)
    }
    
    override var path: String { return "/1/ticketinventory/search" }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(TicketInventory(
            venueId: venueId, date: date
        ))
    }
    
    private struct TicketInventory: Codable {
        let venueId: String
        let date: String
    }
}

class APIResponseTicketInventory: ADApiResponse {
    let data: TicketInventoryResponse
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(TicketInventoryResponse.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
    
    struct TicketInventoryResponse: Decodable {
        let ticketInventory: [TicketInventoryItem]
    }
}

