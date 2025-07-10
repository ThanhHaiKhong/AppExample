//
//  NetworkCoreTests.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import XCTest
@testable import NetworkCore

final class APIClientTests: XCTestCase {
	
	func testFetchMockUser() async throws {
		let config = NetworkConfiguration(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
		let client = DefaultAPIClient(config: config)
		
		let request = Endpoint(path: "users/1")
		
		struct User: Decodable {
			let id: Int
			let name: String
			let username: String
			let email: String
		}
		
		let user: User = try await client.send(request)
		print(user)
		XCTAssertEqual(user.id, 1)
		XCTAssertEqual(user.name, "Leanne Graham")
		XCTAssert(user.email.contains("@"))
	}
}
