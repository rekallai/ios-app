//
//  APIRequestVenue.swift
//  Rekall
//
//  Created by Ray Hunter on 07/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class ProductRequest : ADBaseRequest {
    struct Params:Codable {
        let shopId: String
        let skip: Int
        let limit: Int
    }
    
    let shopId: String
    let skip: Int
    let limit: Int
    init(shopId: String, skip: Int, limit: Int) {
        self.shopId = shopId
        self.skip = skip
        self.limit = limit
    }
    
    override var path: String {
        return "/1/products/search"
    }
    override var method: Moya.Method { return .post }
    override var authorizationType: AuthorizationType { return .bearer }
    override var task: Task { return .requestJSONEncodable(
        Params(shopId: shopId, skip: skip, limit: limit)
    )}
}

class ProductSearchResponse: ADApiResponse {
    let data: [Product]
    let meta: SearchMeta
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Product].self, forKey: .data)
        meta = try container.decode(SearchMeta.self, forKey: .meta)
        try super.init(from: container.superDecoder())
    }
}
