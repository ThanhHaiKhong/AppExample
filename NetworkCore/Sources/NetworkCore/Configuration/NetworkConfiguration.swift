//
//  NetworkConfiguration.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public struct NetworkConfiguration: Sendable {
	public let baseURL: URL
	public let defaultHeaders: [String: String]
	
	public init(baseURL: URL, defaultHeaders: [String: String] = [:]) {
		self.baseURL = baseURL
		self.defaultHeaders = defaultHeaders
	}
}

