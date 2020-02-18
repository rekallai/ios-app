//
//  APIRequestVenue.swift
//  Rekall
//
//  Created by Ray Hunter on 07/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class VenueRequest : ADBaseRequest {
    struct Params:Codable {
        let date: String
        let numDays: Int
        let skip: Int
        let limit: Int
    }
    
    let skip: Int
    let limit: Int
    init(skip: Int, limit: Int) {
        self.skip = skip
        self.limit = limit
    }
    
    override var path: String {
        return "/1/venues/search"
    }
    override var method: Moya.Method { return .post }
    override var task: Task { return .requestJSONEncodable(
        Params(date:Date.todayYearMonthDay(), numDays: 7, skip: skip, limit: limit)
    )}
}

class VenueSearchResponse: ADApiResponse {
    let data: [Venue]
    let meta: SearchMeta
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Venue].self, forKey: .data)
        meta = try container.decode(SearchMeta.self, forKey: .meta)
        try super.init(from: container.superDecoder())
    }
}
