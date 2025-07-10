//
//  Endpoint.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public struct Endpoint: APIRequest {
	public let path: String
	public let method: HTTPMethod
	public let query: [String: String]?
	public let headers: [String: String]?
	public let body: Data?
	
	public init(
		path: String,
		method: HTTPMethod = .get,
		query: [String: String]? = nil,
		headers: [String: String]? = nil,
		body: Data? = nil
	) {
		self.path = path
		self.method = method
		self.query = query
		self.headers = headers
		self.body = body
	}
	
	public func build(with config: NetworkConfiguration) throws -> URLRequest {
		var url = config.baseURL.appendingPathComponent(path)
		if let query = query {
			var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
			components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
			if let newURL = components?.url {
				url = newURL
			}
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.httpBody = body
		config.defaultHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
		headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
		
		return request
	}
}
