//
//  PassViewModel.swift
//  Rekall
//
//  Created by Steve on 9/4/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

class PassViewModel: ViewModel {

    var onSuccess: (([PKPass]) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func loadPasses(idsAndAuthCodes:[(String, String)]) {
        
        let passesGroup = DispatchGroup()
        var results = [PKPass]()
        var lastError: Error?
        let failureErrorMessage = NSLocalizedString("Unable to download passes", comment: "Error message")
                
        for (ticketId, authCode) in idsAndAuthCodes {
            let passRequest = PasskitRequest()
            passRequest.ticketId = ticketId
            passRequest.authCode = authCode
            passesGroup.enter()
            
            request(passRequest){ result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        do {
                            let pass = try PKPass(data: response.data)
                            results.append(pass)
                        } catch {
                            lastError = error
                        }
                    case .failure(let error):
                        lastError = error
                    }
                    
                    passesGroup.leave()
                }
            }
        }
        
        passesGroup.notify(queue: DispatchQueue.main) { [weak self] in
            if idsAndAuthCodes.count == results.count {
                self?.onSuccess?(results)
            } else {
                self?.onFailure?(lastError?.localizedDescription ?? failureErrorMessage)
            }
        }

    }
}
