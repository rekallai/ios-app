//
//  Models.swift
//  Snoutscan
//
//  Created by Levi McCallum on 4/8/19.
//  Copyright © 2019 Rekall. All rights reserved.
//

import Foundation
import Moya

enum APIError: Error {
    case noToken
    case emailPasswordNoMatch
    case unknown(String)
    case underlying(MoyaError)
    case apiResponseError(Int)
    case tokenExpired
    case emailAlreadyUsed

    var localizedDescription: String {
        switch self {
        case .noToken:
            return NSLocalizedString("You're not currently logged in.", comment: "Error message")
        case .emailPasswordNoMatch:
            return NSLocalizedString("Email and password combination not found.", comment: "Error message")
        case .tokenExpired:
            return NSLocalizedString("You have been logged out. Please log in again.", comment: "Error message")
        case .unknown(let message):
            return message
        case .underlying(let error):
            return error.localizedDescription
        case .apiResponseError(let errorCode):
            return NSLocalizedString("Server returned code \(errorCode)", comment: "Error message")
        case .emailAlreadyUsed:
            return NSLocalizedString("A user with that email already exists", comment: "Error message")
        }
    }
    
    init(response: APIErrorResponse) {
        switch response.error.message {
        case "email password combination does not match":
            self = .emailPasswordNoMatch
        case "user associated to token could not not be found": fallthrough
        case "jwt expired": fallthrough
        case "invalid signature":
            self = .tokenExpired
        case "A user with that email already exists":
            self = .emailAlreadyUsed
        default:
            self = .unknown(response.error.message)
        }
    }
}

struct APIErrorResponse: Codable {
    struct Payload: Codable {
        let message: String
    }
    
    let error: Payload
}

