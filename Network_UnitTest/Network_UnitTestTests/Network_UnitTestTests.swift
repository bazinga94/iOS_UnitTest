//
//  Network_UnitTestTests.swift
//  Network_UnitTestTests
//
//  Created by Jongho Lee on 2021/04/10.
//

import XCTest
@testable import Network_UnitTest

class MockURLSessionDataTask: URLSessionDataTask {
	override init() { }
	var resumeDidCall: () -> Void = {}

	override func resume() {
		resumeDidCall()
	}
}

class MockURLSession: URLSessionProtocol {
	var makeRequestFail: Bool
	init(makeRequestFail: Bool = false) {
		self.makeRequestFail = makeRequestFail
	}

	var sessionDataTask: MockURLSessionDataTask?

	// dataTask 를 구현합니다.
	func dataTask(with request: URLRequest,
				  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

		// 성공시 callback 으로 넘겨줄 response
		let successResponse = HTTPURLResponse(url: JokesAPI.randomJokes.url,
											  statusCode: 200,
											  httpVersion: "2",
											  headerFields: nil)
		// 실패시 callback 으로 넘겨줄 response
		let failureResponse = HTTPURLResponse(url: JokesAPI.randomJokes.url,
											  statusCode: 400,
											  httpVersion: "2",
											  headerFields: nil)

		let sessionDataTask = MockURLSessionDataTask()

		// resume() 이 호출되면 completionHandler() 가 호출되도록 합니다.
		sessionDataTask.resumeDidCall = {
			if self.makeRequestFail {
				completionHandler(nil, failureResponse, nil)
			} else {
				completionHandler(JokesAPI.randomJokes.sampleData, successResponse, nil)
			}
		}
		self.sessionDataTask = sessionDataTask
		return sessionDataTask
	}
}

class Network_UnitTestTests: XCTestCase {

	var networkManager: NetworkManager!

    override func setUpWithError() throws {
		networkManager = .init(session: MockURLSession())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample_success() throws {
		let expectation = XCTestExpectation()	// 비동기 작업이 완료될 때 까지 대기 하다가 처리 필요
		let response = try? JSONDecoder().decode(JokeResponse.self, from: JokesAPI.randomJokes.sampleData)

		networkManager.fetchRequest(url: JokesAPI.randomJokes.url, type: .GET) { (result: Result<JokeResponse, APIError>) in
			switch result {
				case .success(let model):
					XCTAssertEqual(model.value.id, response?.value.id)
					XCTAssertEqual(model.value.joke, response?.value.joke)
				case .failure(_):
					XCTFail()
			}
			expectation.fulfill()	// 작업 완료 알림
		}

		wait(for: [expectation], timeout: 3.0)	// 이 위치에서 작업이 완료될 때 까지 2초 대기
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

	func testExample_failure() throws {
		networkManager = .init(session: MockURLSession(makeRequestFail: true))
		let expectation = XCTestExpectation()

		networkManager.fetchRequest(url: JokesAPI.randomJokes.url, type: .GET) { (result: Result<JokeResponse, APIError>) in
			switch result {
				case .success:
					XCTFail()
				case .failure(let error):
					XCTAssertEqual(error, .httpStatus)
			}
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 3.0)
	}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
