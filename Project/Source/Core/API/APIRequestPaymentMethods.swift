//
//  APIRequestPaymentMethods.swift
//  Rekall
//
//  Created by Ray Hunter on 15/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class APIRequestPaymentMethods: ADBaseRequest {
    override var path: String { return "/1/payment/methods" }
    override var authorizationType: AuthorizationType { return .bearer }
    override var method: Moya.Method { return .get }
    override var task: Task { return .requestPlain }
}

class PaymentMethodsResponse: ADApiResponse {
    let data:[PaymentMethod]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([PaymentMethod].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
    
    struct CreditCard: Codable {
        let brand: String
        let last4: String
        let exp_month: Int
        let exp_year: Int
    }
    
    struct PaymentMethod: Codable {
        let id: String
        let type: String
        let card: CreditCard?
    }
}


class APIRequestPayment: ADBaseRequest {
    var amount: Int
    var paymentMethodId: String
    
    init(amount: Int, paymentMethodId: String){
        self.amount = amount
        self.paymentMethodId = paymentMethodId
    }
    
    override var path: String { return "/1/payment" }
    override var authorizationType: AuthorizationType { return .bearer }
    override var method: Moya.Method { return .post }
    override var task: Task { return .requestJSONEncodable(PaymentPayload(amount: amount,
                                                                          paymentMethodId: paymentMethodId))
    }
    
    private struct PaymentPayload: Codable {
        let amount: Int
        let paymentMethodId: String
    }
}

class PaymentResponse: ADApiResponse {
    let data:[PaymentIntentData]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([PaymentIntentData].self, forKey: .data)
        try super.init(from: container.superDecoder())
    }
    
    struct PaymentIntentData: Codable {
        let id: String
        let object: String
        let amount: Int
        let amount_capturable: Int
        let amount_received: Int
        let client_secret: String
        let payment_method: String
    }
}
