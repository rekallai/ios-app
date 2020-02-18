//
//  APIRequestOrder.swift
//  Rekall
//
//  Created by Steve on 7/11/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Moya

class PasskitRequest: ADBaseRequest {

    private let passTypeIdentifier = Environment.shared.applePasskitTypeIdentifier
    var ticketId: String?
    var authCode: String?

    override var path: String {
        return "/1/passkit/v1/passes/\(passTypeIdentifier)/\(ticketId ?? "")"
    }

    override var headers: [String : String]? {
        return ["Authorization" : "ApplePass \(authCode ?? "")"]
    }

    override var authorizationType: AuthorizationType { return .none }
    override var method: Moya.Method { return .get }
    override var task: Task {
        return .requestPlain
    }
}
