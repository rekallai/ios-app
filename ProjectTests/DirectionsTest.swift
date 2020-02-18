//
//  DirectionsTest.swift
//  RekallTests
//
//  Created by Ray Hunter on 15/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
import MapKit

class DirectionsTest: ADTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @available(iOS 13.0, *)
    func testExample() {
        
        let p1 = MKMapPoint(x: 1, y: 1)
        let p2 = MKMapPoint(x: 5, y: 5)
        let p3 = MKMapPoint(x: 1, y: 9)
        XCTAssertEqual(Directions.angle(p1: p1, p2: p2, p3: p3), -90.0)
        
        let p4 = MKMapPoint(x: 9, y: 1)
        XCTAssertEqual(Directions.angle(p1: p1, p2: p2, p3: p4), 90.0)

        let p5 = MKMapPoint(x: 10, y: 10)
        XCTAssertEqual(Directions.angle(p1: p1, p2: p2, p3: p5), 0.0)

        let p6 = MKMapPoint(x: 5, y: 10)
        XCTAssertEqual(Directions.angle(p1: p1, p2: p2, p3: p6), -45.0)
        
        XCTAssertEqual(Directions.angle(p1: p6, p2: p2, p3: p1), 45.0)

    }

}
