//
//  TaskListTest.swift
//  practical-skill-test-iosTests
//
//  Created by 田辺信之 on 2019/05/09.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import XCTest
@testable import practical_skill_test_ios

class TaskListTest: XCTestCase {

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

    func testChangeTask() {
        let now = Date()
        let formatter = DateFormatter()
        guard let dateString = formatter.stringByDefaultLocale(from: now) else { fatalError("can not convert: Logic Failure") }
        let list: [String: TaskInList]? = ["id": TaskInList(title: "title", description: "description", createdAt: "05/08/2019, 19:10:17", updatedAt: "05/08/2019, 19:10:17")]
        var task = TaskList(data: list)
        _ = task.change(of: "id", to: UpdatedTask(title: "updated", description: "updated", updatedAt: dateString))
        XCTAssertEqual(task.tasks.first!.id, "id")
        XCTAssertEqual(task.tasks.first!.title, "updated")
        XCTAssertEqual(task.tasks.first!.description, "updated")
        XCTAssertNotEqual(task.tasks.first!.updatedAt, "05/08/2019, 19:10:17")
    }

    func testDeleteTask() {
        let list: [String: TaskInList]? = ["id": TaskInList(title: "title", description: "description", createdAt: "05/08/2019, 19:10:17", updatedAt: "05/08/2019, 19:10:17")]
        var task = TaskList(data: list)
        _ = task.delete(of: "id")
        XCTAssertEqual(task.tasks.isEmpty, true)
    }

}
