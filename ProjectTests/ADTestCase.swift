//
//  ADTestCase.swift
//  RekallTests
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
import Moya

class ADTestCase: XCTestCase {

    private(set) lazy var api: APIProvider = {
        return APIProvider(
            plugins: [AccessTokenPlugin(tokenClosure: {
                return self.store.state.token ?? ""
            })]
        )
    }()
    
    let store = Store(initialState: AppState.fromDisk())

}
