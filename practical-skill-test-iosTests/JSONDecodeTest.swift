//
//  JSONDecodeTest.swift
//  practical-skill-test-iosTests
//
//  Created by 田辺信之 on 2019/05/03.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import XCTest
@testable import practical_skill_test_ios

class JSONDecodeTest: XCTestCase {

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
    
    func testDecodeToTaskData() {
        let data = """
{
  "-LdvCzhfENNENh17ARpt" : {
    "title" : "t",
    "description" : "tanabe",
    "createdAt" : "2019/05/04 08:09:42",
    "updatedAt" : "2019/05/04 08:09:42"
  },
  "alanisawesome" : {
    "title" : "t",
    "description" : "tanabe",
    "createdAt" : "2019/05/02 08:09:42",
    "updatedAt" : "2019/05/02 08:09:42"
  }
}
""".data(using: .utf8)!
        let result = try! JSONDecoder().decode([String: TaskData].self, from: data)
        let taskList = TaskList(data: result)
        XCTAssertEqual("alanisawesome", taskList.tasks[0].id)
        XCTAssertEqual("-LdvCzhfENNENh17ARpt", taskList.tasks[1].id)
        
    }
    
    func testDecodeToPostResponse() {
        let data = """
{"name":"-LdvDClk8XwSU8tIPf9y"}
""".data(using: .utf8)!
        let result = try! JSONDecoder().decode(PostResponse.self, from: data)
        XCTAssertEqual(result.name, "-LdvDClk8XwSU8tIPf9y")
    }
}
