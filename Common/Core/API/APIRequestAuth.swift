//
//  APIRequestAuth.swift
//  Rekall
//
//  Created by Ray Hunter on 07/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class AuthRequestLogin : ADBaseRequest {
    var email = ""
    var password = ""
    
    override var path: String { return "/1/auth/login" }
    override var method: Moya.Method { return .post }
    override var authorizationType: AuthorizationType { return .none }
    override var task: Task { return .requestJSONEncodable(APIRequest.AuthLogin(email: email, password: password)) }
}

struct AuthToken: Codable {
    let token: String
}

class AuthResponseLogin: ADApiResponse {
    let data: AuthToken
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(AuthToken.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}


class AuthRequestRegister : ADBaseRequest {
    var email = ""
    var firstName = ""
    var lastName = ""
    var password = ""
    
    override var path: String { return "/1/auth/register" }
    override var method: Moya.Method { return .post }
    override var authorizationType: AuthorizationType { return .none }
    override var task: Task {
        return .requestJSONEncodable(AuthRegister(email: email,
                                                  name: "\(firstName) \(lastName)",
                                                  password: password))
    }
    
    private struct AuthRegister: Codable {
        let email: String
        let name: String
        let password: String
    }
}

struct OptIns: Codable {
    var termsAccepted: Bool?
}

class AuthResponseRegister: ADApiResponse {
    let data: AuthToken
    
    // Subclass of first decodable must provide own decoding init
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(AuthToken.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
