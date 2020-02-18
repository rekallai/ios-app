//
//  AnalyticsTests.swift
//  RekallTests
//
//  Created by Ray Hunter on 25/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
import Analytics
@testable import Project

class AnalyticsTests: XCTestCase {
    func testEvent() {
        ADAnalytics.shared.track(event: "TestEvent")
        SEGAnalytics.shared().flush()
    }
    
    func testEventWithParameters() {
        ADAnalytics.shared.track(event: "TestEvent", properties: ["TestKey" : "TestValue"])
        SEGAnalytics.shared().flush()
    }
}
