//
//  API.swift
//  Snoutscan
//
//  Created by Levi McCallum on 4/4/19.
//  Copyright © 2019 Rekall. All rights reserved.
//

import Foundation
import Moya

typealias APIProvider = MoyaProvider<ADBaseRequest>

extension APIProvider {
    @discardableResult
    func storeRequest(
        _ target: ADBaseRequest,
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none,
        completion: @escaping (_ result: Result<Moya.Response, APIError>) -> Void
        ) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            switch result {
            case .success(let response):
                do {
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    
                    // Network call successful, valid server response code
                    completion(.success(successResponse))
                } catch (let error) {
                    
                    // Network call successful, bad server response code
                    if let apiError = try? response.map(APIErrorResponse.self){
                        
                        // We are ready to handle the error
                        completion(.failure(APIError(response: apiError)))
                    } else {
                        
                        // An error we weren't expecting
                        completion(.failure(.unknown(error.localizedDescription)))
                    }
                }
            case .failure(let moyaError):
                
                // Network call failed
                if let resp = moyaError.response,
                    let apiError = try? resp.map(APIErrorResponse.self) {
                    completion(.failure(APIError(response: apiError)))
                } else {
                    completion(.failure(.underlying(moyaError)))
                }
            }
        }
    }
}
