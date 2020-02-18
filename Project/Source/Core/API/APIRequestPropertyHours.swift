//
//  APIPropertyHours.swift
//  Rekall
//
//  Created by Ray Hunter on 19/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class APIRequestPropertyHours : ADBaseRequest {    
    var date: String
    
    init(date: String) {
        self.date = date
    }
    
    override var baseURL: URL {
        return URL(string: Environment.shared.apiBaseUrl + "/1/property/openinghours?date=\(date)&numDays=2")!
    }
    override var method: Moya.Method { return .get }
    override var task: Task { return .requestPlain }
}

class APIResponsePropertyHours: ADApiResponse {
    let data: OpeningHours
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(OpeningHours.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
