//
//  PxChallengeUITests.swift
//  PxChallengeUITests
//
//  Created by Paul Floussov on 2017-04-20.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import XCTest

class PxChallengeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testInitialLoad() {
        sleep(3)
        XCTAssert(XCUIApplication().collectionViews.cells.count > 1)
    }
    
    func testPopulateUsername() {
        XCUIApplication().collectionViews["PopularPageCollectionView"].children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        
        XCTAssert(XCUIApplication().staticTexts.element(matching: .any, identifier: "UserNameLabel").label != "username")
    }
    
}
