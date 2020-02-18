//
//  APIRequestAttribute.swift
//  Rekall
//
//  Created by Steve on 8/13/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class AttributeRequest: ADBaseRequest {
    struct Params:Encodable {}
    override var path:String {
        return "/1/metadata/attributes/search"
    }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(Params())
    }
}

class AttributeResponse: ADApiResponse {
    let data:[Attribute]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Attribute].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
