//
//  APIRequestInterestTopic.swift
//  Rekall
//
//  Created by Steve on 6/24/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class InterestTopicRequest: ADBaseRequest {
    struct Params:Encodable {}
    override var path: String {
        return "/1/metadata/interesttopics/search"
    }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(Params())
    }
}

class InterestTopicSearchResponse: ADApiResponse {
    let data: [InterestTopic]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([InterestTopic].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
