//
//  PaymentTests.swift
//  RekallUITests
//
//  Created by Ray Hunter on 22/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import XCTest
import CoreData

class PaymentTests: XCTestCase {

    var testFirstname: String {
        let now = Date()
        let c = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        return "name\(c.year!)\(c.month!)\(c.day!)\(c.hour!)\(c.minute!)\(c.second!)"
    }
        
    var testEmail: String {
        return "\(testFirstname)@testdomain.com"
    }
    var testPassword = "TestPassword12"


    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments.append("--uitestingresetappstate")
        app.launch()
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        app.launchArguments.append("--uitestingresetappstate")
//        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    func testAABasicCardSuccess() {
        let app = XCUIApplication()
        app.launchArguments.append("--uitestingresetappstate")
        app.launch()

        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Check Out"))

        performCreditCardEntry(ccNumber: "4242424242424242",
                               cvc: "123",
                               month: "12",
                               year: "21",
                               zip: "90210")
        
        let youreAllSet = app.staticTexts ["You're all set."]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testABBasicCardSavedPurchase() {
        let app = XCUIApplication()
        app.launch()

        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Confirm Tickets"))

        let youreAllSet = app.staticTexts ["You're all set."]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testBA3DSecure() {
        let app = XCUIApplication()
        app.launchArguments.append("--uitestingresetappstate")
        app.launch()

        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Check Out"))

        performCreditCardEntry(ccNumber: "4000000000003063",
                               cvc: "123",
                               month: "12",
                               year: "21",
                               zip: "90210")
        
        complete3DSecureProcess()

        let exists = NSPredicate(format: "exists == 1")
        let youreAllSet = app.staticTexts ["You're all set."]
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    func testBB3DSecureSaved() {
        let app = XCUIApplication()
        app.launch()

        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Confirm Tickets"))

        complete3DSecureProcess()

        let exists = NSPredicate(format: "exists == 1")
        let youreAllSet = app.staticTexts ["You're all set."]
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    private func complete3DSecureProcess() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let completeAuthBtn = app.buttons["COMPLETE AUTHENTICATION"]
        expectation(for: exists, evaluatedWith: completeAuthBtn, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        
        sleep(1)
        
        completeAuthBtn.tap()
        
        let closeBtn = app.buttons["Close"]
        expectation(for: exists, evaluatedWith: closeBtn, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
        closeBtn.tap()
    }
    
    func testCA3DSecure2() {
        let app = XCUIApplication()
        
        app.launchArguments.append("--uitestingresetappstate")
        app.launch()
        
        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Check Out"))

        performCreditCardEntry(ccNumber: "4000000000003220",
                               cvc: "123",
                               month: "12",
                               year: "21",
                               zip: "90210")
        
        complete3DSecure2Process()
        
        let exists = NSPredicate(format: "exists == 1")
        let youreAllSet = app.staticTexts ["You're all set."]
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    func testCA3DSecure2Saved() {
        let app = XCUIApplication()
        app.launch()
        
        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Confirm Tickets"))

        complete3DSecure2Process()
        
        let exists = NSPredicate(format: "exists == 1")
        let youreAllSet = app.staticTexts ["You're all set."]
        expectation(for: exists, evaluatedWith: youreAllSet, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    private func complete3DSecure2Process() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let completeAuthBtn = app.buttons["Complete Authentication"]
        expectation(for: exists, evaluatedWith: completeAuthBtn, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        
        sleep(1)
        
        completeAuthBtn.tap()
    }
    
    
    func testDACardDeclined() {
        let app = XCUIApplication()

        app.launchArguments.append("--uitestingresetappstate")
        app.launch()
        
        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Check Out"))

        performCreditCardEntry(ccNumber: "4000000000001629",
                               cvc: "123",
                               month: "12",
                               year: "21",
                               zip: "90210")
        
        
        let exists = NSPredicate(format: "exists == 1")
        
        let alert = app.alerts.element.staticTexts["Your card's number is invalid"]
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    func testEACvcCheckFailed() {
        let app = XCUIApplication()

        app.launchArguments.append("--uitestingresetappstate")
        app.launch()
        
        navigateFromHomeScreenAndSelectATicket()
        XCTAssert(tapFirstHittableButtonWithText(text: "Check Out"))

        performCreditCardEntry(ccNumber: "4000000000000101",
                               cvc: "123",
                               month: "12",
                               year: "21",
                               zip: "90210")
        
        
        let exists = NSPredicate(format: "exists == 1")
        
        let alert = app.alerts.element.staticTexts["Your card's security code is incorrect."]
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    
    private func performCreditCardEntry(ccNumber: String, cvc: String, month: String,
                                        year: String, zip: String) {

        let app = XCUIApplication()
                        
        app.staticTexts["Full Name"].tap()
        app.typeText(testFirstname)
        app.staticTexts["Email"].tap()
        app.typeText(testEmail)
        app.staticTexts["Card Number"].tap()
        app.typeText(ccNumber)
        app.staticTexts["Security Code"].tap()
        app.typeText(cvc)
        app.staticTexts["Month"].tap()
        app.typeText(month)
        app.staticTexts["Year"].tap()
        app.typeText(year)
        app.staticTexts["Zip Code"].tap()
        app.typeText(zip)
        
        app.swipeUp()

        XCTAssert(tapFirstHittableButtonWithText(text: "Review Your Order"))
        
        app.swipeUp()
        
        XCTAssert(tapFirstHittableButtonWithText(text: "Purchase"))
    }
    
    
    func navigateFromHomeScreenAndSelectATicket() {
        let app = XCUIApplication()
        
        let button = app.buttons["For You"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: button, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
        
        app.tabBars.buttons["Attractions"].tap()
        
        XCTAssert(tapFirstHittableButtonWithText(text: "Tickets"))

        // Steppers are gone - now just look for the button
        let stepper = app.buttons["Increment"]
        expectation(for: exists, evaluatedWith: stepper, handler: nil)
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssert(tapFirstHittableButtonWithText(text: "Increment"))

        app.swipeUp()
    }
    

    func tapFirstHittableButtonWithText(text: String) -> Bool {
        let app = XCUIApplication()

        for i in 0..<app.buttons.count {
            let button = app.buttons.element(boundBy: i)
            if button.isHittable && button.label==text {
                button.tap()
                return true
            }
        }
        
        return false
    }
}
