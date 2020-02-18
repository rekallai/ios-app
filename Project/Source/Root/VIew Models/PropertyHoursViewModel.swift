//
//  PropertyHoursViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 19/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class PropertyHoursViewModel: ViewModel {

    var openingHours: OpeningHours?
    
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?

    func fetchHours() {
        let req = APIRequestPropertyHours(date: Date.todayYearMonthDay())
        request(req) { [weak self] result in
            switch result {
            case .success(let response):
                self?.processApiResponse(response: response)
            case .failure(let error):
                print("ERROR: property hours api call failed: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.onFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processApiResponse(response: Moya.Response){
        do {
            let apiResponse = try decodeResponse(APIResponsePropertyHours.self, response: response, moc: nil)
            DispatchQueue.main.async { [weak self] in
                self?.openingHours = apiResponse.data
                self?.onSuccess?()
            }
        } catch {
            print("ERROR: PropertyHoursViewModel: processApiResponse \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.onFailure?(error.localizedDescription)
            }
        }
    }
}
