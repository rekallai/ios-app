//
//  APITests.swift
//  RekallTests
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
import Moya

class APITests: ADTestCase {
    
    static var testUsername: String = {
        let now = Date()
        let c = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        return "username\(c.year!)\(c.month!)\(c.day!)\(c.hour!)\(c.minute!)\(c.second!)"
    }()

    var testLastname = "lastname"
    lazy var testEmail = "\(Self.testUsername)@testdomain.com"
    var testPassword = "TestPassword12"
        
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testARegisterUser() {
        let authVM = AuthViewModel(api: api, store: store)
        
        let registerExpectation = expectation(description: "Register Success")
        authVM.onRegisterSuccess = {
            registerExpectation.fulfill()
        }
        authVM.onRegisterFailure = { failure in
            XCTFail()
        }
        
        authVM.firstName = Self.testUsername
        authVM.lastName = testLastname
        authVM.email = testEmail
        authVM.password = testPassword
        authVM.submitRegister()
        
        waitForExpectations(timeout:  3.0, handler: nil)
    }
    
    func testBUserAlreadyRegistered() {
        let authVM = AuthViewModel(api: api, store: store)
        
        let registerExpectation = expectation(description: "Register Success")
        authVM.onRegisterSuccess = {
            XCTFail()
        }
        authVM.onRegisterFailure = { failure in
            registerExpectation.fulfill()
        }
        
        authVM.firstName = Self.testUsername
        authVM.lastName = testLastname
        authVM.email = testEmail
        authVM.password = testPassword
        authVM.submitRegister()
        
        waitForExpectations(timeout:  3.0, handler: nil)
    }


    func testCLogin() {
        let authVM = AuthViewModel(api: api, store: store)
        
        let loginExpectation = expectation(description: "Login Success")
        authVM.onLoginSuccess = {
            loginExpectation.fulfill()
        }
        authVM.onLoginFailure = { failure in
            XCTFail()
        }
        
        authVM.submitLogin(email: testEmail, password: testPassword)
        
        waitForExpectations(timeout:  3.0, handler: nil)
    }
    
    
    func testDLoginFailure() {
        let authVM = AuthViewModel(api: api, store: store)
        
        let loginExpectation = expectation(description: "Login Success")
        authVM.onLoginSuccess = {
            XCTFail()
        }
        authVM.onLoginFailure = { failure in
            loginExpectation.fulfill()
        }
        
        authVM.submitLogin(email: testEmail, password: "TheWrongPassword")
        
        waitForExpectations(timeout:  3.0, handler: nil)
    }
}
