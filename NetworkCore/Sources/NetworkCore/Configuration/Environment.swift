//
//  Environment.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public struct Environment {
	public let baseURL: URL
	public let defaultHeaders: [String: String]
	
	public init(
		baseURL: URL,
		headers: [String: String] = [
			"Content-Type": "application/json",
			"Accept": "application/json"
		]
	) {
		self.baseURL = baseURL
		self.defaultHeaders = headers
	}
}
