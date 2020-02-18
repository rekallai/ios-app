//
//  APIRequestEvent.swift
//  Rekall
//
//  Created by Ray Hunter on 14/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class EventRequest: ADBaseRequest {
    struct Params:Codable {
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
        return "/1/events/search"
    }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(
            Params(skip: skip, limit: limit)
        )
    }
}

class EventSearchResponse: ADApiResponse {
    let data: [Event]
    let meta: SearchMeta
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Event].self, forKey: .data)
        meta = try container.decode(SearchMeta.self, forKey: .meta)
        try super.init(from: container.superDecoder())
    }
}
