//
//  TicketsTests.swift
//  Rekall
//
//  Created by Ray Hunter on 30/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
@testable import Project

class TicketsTests: ADTestCase {
    
    func testTicketRetrieval() {
        let ptvm = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
        
        let venueExpectation = expectation(description: "Tickets API")
        ptvm.onUpdateSuccess = {
            venueExpectation.fulfill()
        }
        ptvm.onUpdateFailure = { failure in
            XCTFail()
        }
        
        ptvm.reloadTicketsFromBackend()
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

}
