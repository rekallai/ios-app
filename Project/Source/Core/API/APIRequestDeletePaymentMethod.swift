//
//  APIRequestPaymentMethods.swift
//  Rekall
//
//  Created by Ray Hunter on 15/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class APIRequestDeletePaymentMethod: ADBaseRequest {
    
    let methodId: String
    
    init(methodId: String) {
        self.methodId = methodId
    }
    
    override var path: String { return "/1/payment/methods/\(methodId)" }
    override var authorizationType: AuthorizationType { return .bearer }
    override var method: Moya.Method { return .delete }
    override var task: Task { return .requestPlain }
}
