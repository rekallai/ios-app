//
//  APIShopTests.swift
//  RekallTests
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
@testable import Project

class APIShopTests: ADTestCase {

    func testEListShops() {
        let shopVM = ShopViewModel(api: api, store: store)
        
        let shopExpectation = expectation(description: "Shop API")
        shopVM.onUpdateSuccess = {
            shopExpectation.fulfill()
        }
        shopVM.onUpdateFailure = { failure in
            XCTFail()
        }
        
        shopVM.loadShops()
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

}
