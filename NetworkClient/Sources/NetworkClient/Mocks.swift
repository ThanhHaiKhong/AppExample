//
//  Mocks.swift
//  NetworkClient
//
//  Created by Thanh Hai Khong on 11/7/25.
//

import Dependencies

extension DependencyValues {
	public var networkClient: NetworkClient {
		get { self[NetworkClient.self] }
		set { self[NetworkClient.self] = newValue }
	}
}

extension NetworkClient: TestDependencyKey {
	public static var testValue: NetworkClient {
		NetworkClient()
	}
	
	public static var previewValue: NetworkClient {
		NetworkClient()
	}
}
