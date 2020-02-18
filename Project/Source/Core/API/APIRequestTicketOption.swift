//
//  APIRequestTicketOption.swift
//  Rekall
//
//  Created by Steve on 7/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

let ticketOptionPath = "/1/ticketoptions/search"

class TicketOptionRequest: ADBaseRequest {
    var venueId:String?
    var eventId:String?
    override var path: String {
        return ticketOptionPath
    }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(APIRequest.TicketOption(
            venueId: venueId, eventId: eventId
        ))
    }
}

class TicketOptionResponse: ADApiResponse {
    let data: [TicketOption]
    let meta: SearchMeta
    
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([TicketOption].self, forKey: .data)
        meta = try container.decode(SearchMeta.self, forKey: .meta)
        try super.init(from: container.superDecoder())
    }
}
