//
//  APIVenueTests.swift
//  RekallTests
//
//  Created by Ray Hunter on 05/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
@testable import Project

class APIVenueTests: ADTestCase {

    func testEListVenues() {
        let venueVM = VenueViewModel(api: api, store: store)
        
        let venueExpectation = expectation(description: "Venue API")
        venueVM.onUpdateSuccess = {
            venueExpectation.fulfill()
        }
        venueVM.onUpdateFailure = { failure in
            XCTFail()
        }
        
        venueVM.loadVenues()
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }

}
