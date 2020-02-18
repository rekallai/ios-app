//
//  CreditCardTests.swift
//  RekallTests
//
//  Created by Ray Hunter on 22/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
@testable import Project

class CreditCardTests: ADTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicPayment() {
        let paymentViewModel = PaymentViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
        paymentViewModel.onTicketOptionsSuccess = {
            
        }
        
        let vc = UIViewController()
        paymentViewModel.payWithCreditCard(hostViewController: vc)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
