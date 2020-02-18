//
//  APIRequestCategory.swift
//  Rekall
//
//  Created by Steve on 8/5/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class CategoryRequest: ADBaseRequest {
    struct Params:Encodable {}
    override var path:String {
        return "/1/metadata/categories/search"
    }
    override var method: Moya.Method { return .post }
    override var task: Task {
        return .requestJSONEncodable(Params())
    }
}

class CategoryResponse: ADApiResponse {
    let data:[Category]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Category].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
