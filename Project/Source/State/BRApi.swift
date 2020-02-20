//
//  ADApi.swift
//  Rekall
//
//  Created by Ray Hunter on 06/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya

class BRApi: NSObject {
    
    static let shared = BRApi()

    private(set) lazy var api: APIProvider = {
        return APIProvider(
            plugins: [AccessTokenPlugin(tokenClosure: {
                return self.store.state.token ?? ""
            })]
        )
    }()
    
    let store = Store(initialState: AppState.fromDisk())
}
