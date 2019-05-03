//
//  ExtensionTest.swift
//  practical-skill-test-iosTests
//
//  Created by 田辺信之 on 2019/05/04.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import XCTest
@testable import practical_skill_test_ios

class ExtensionTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testStringByDefaultLocale() {
        let now = Date()
        let f = DateFormatter()
        XCTAssertNotNil(f.stringByDefaultLocale(from: now))
    }
    
    func testDateByDefaultLocale() {
        let string = "2019/05/04 08:09:42"
        let f = DateFormatter()
        XCTAssertNotNil(f.dateByDefaultLocale(from: string))
    }
}
