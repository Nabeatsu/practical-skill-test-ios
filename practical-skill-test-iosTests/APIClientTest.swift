//
//  APIClientTest.swift
//  practical-skill-test-iosTests
//
//  Created by 田辺信之 on 2019/05/01.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import XCTest
@testable import practical_skill_test_ios

class APIClientTest: XCTestCase {

    struct GitHubAPI: APIClientDelegate {
        let text: String
        static func from(response: Response) -> Either<TransformError, APIClientTest.GitHubAPI> {
            switch response.statusCode {
            case .ok:
                guard let text = String(data: response.payload, encoding: .utf8) else {
                    return .left(.malformedData(debugInfo: "UTF-8へのencodingに失敗"))
                }
                return .right(GitHubAPI(text: text))
            default:
                return .left(.unexpectedStatusCode(debugInfo: "\(response.statusCode)"))
            }
        }
    }

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
    
    func testRequest()  {
        let imput: Request = (
            url: URL(string: "https://api.github.com/zen")!,
            queries: [],
            headers: [:],
            methodAndPayload: .get
        )
        APIClient.call(with: imput) { _ in
        }
    }
    
    func testResponse() {
        let response: Response = (
            statusCode: .ok,
            headers: [:],
            payload: "this is response text".data(using: .utf8)!
        )
        
        let errorOrResult = GitHubAPI.from(response: response)
        switch errorOrResult {
        case let .left(error):
            XCTFail("\(error)")
        case let .right(result):
            XCTAssertEqual(result.text, "this is response text")
        }
    }
    
    func testAPIRequest() {
        let expectation = self.expectation(description: "APIリクエストが行えているかのテスト")
        let input: Input = (
            url: URL(string: "https://api.github.com/zen")!,
            queries: [],
            headers: [:],
            methodAndPayload: .get
        )
        APIClient.call(with: input) { output in
            switch output {
            case let .noResponse(connectionError):
                switch connectionError {
                case let .malformedURL(string):
                    XCTFail("\(string)")
                case let .noDataOrNoResponse(string):
                    XCTFail("\(string)")
                }
            case let .hasResponse(response):
                let errorOrResult = GitHubAPI.from(response: response)
                XCTAssertNotNil(errorOrResult.right)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }
    
    func testGitHubAPI() {
        let expectation = self.expectation(description: "GitHubのAPI")
        let input: Input = (
            url: URL(string: "https://api.github.com/zen")!,
            queries: [],
            headers: [:],
            methodAndPayload: .get
        )
        APIClient.call(with: input) { output in
            switch output {
            case .noResponse:
                XCTFail("レスポンスなし")
            case let .hasResponse(response):
                let errorOrResult = GitHubAPI.from(response: response)
                XCTAssertNotNil(errorOrResult.right)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }
    
    func testGitHubAPIFetch() {
        let expectation = self.expectation(description: "GitHubのZen APIへのfetchを使ったリクエスト")
        GitHubAPI.fetch(
            method: .get,
            apiPath: "https://api.github.com/zen") { errorResult in
                switch errorResult {
                case let .left(error):
                    XCTFail("\(error)")
                case let .right(result):
                    XCTAssertNotNil(result.text)
                }
                expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
