//
//  APIRequest.swift
//  Snoutscan
//
//  Created by Levi McCallum on 4/8/19.
//  Copyright © 2019 Rekall. All rights reserved.
//

import Foundation
import Moya
import CoreData

struct APIRequest {    
    struct AuthLogin: Codable {
        let email: String
        let password: String
    }    
}

class ADBaseRequest: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: AppEnvironment.shared.apiBaseUrl)! }
    var sampleData: Data { return Data() }
    var headers: [String : String]? { return nil }

    var path: String { return "" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestPlain }
    var authorizationType: AuthorizationType { return .none }
}

class ADApiResponse: Decodable { }

struct SearchMeta: Codable {
    let total: Int
    let skip: Int
    let limit: Int
}
