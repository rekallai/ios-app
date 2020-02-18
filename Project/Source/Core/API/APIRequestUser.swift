//
//  APIRequestUser.swift
//  Rekall
//
//  Created by Steve on 6/25/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

let userRequestPath = "/1/users/me"

class UserRequest: ADBaseRequest {
    override var path: String {
        return userRequestPath
    }
    override var authorizationType: AuthorizationType { return .bearer }
    override var method: Moya.Method { return .get }
    override var task: Task {
        return .requestPlain
    }
}

class UserUpdateRequest: ADBaseRequest {
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var interestTopics: [String]?
    var favoriteVenueIds: [String]?
    var optIns: OptIns?
    override var path: String {
        return userRequestPath
    }
    override var authorizationType: AuthorizationType { return .bearer }
    override var method: Moya.Method { return .patch }
    override var task: Task {
        return .requestJSONEncodable(
            UserUpdateAPIField(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                interestTopics: interestTopics,
                favoriteVenueIds: favoriteVenueIds,
                optIns: optIns
            )
        )
    }
    
    private struct UserUpdateAPIField: Codable {
        let firstName: String?
        let lastName: String?
        let email: String?
        let password: String?
        let interestTopics: [String]?
        let favoriteVenueIds: [String]?
        let optIns: OptIns?
    }
}

class UserResponse: ADApiResponse {
    let data:User
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        data = try container.decode(User.self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
}
