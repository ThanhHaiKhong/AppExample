//
//  APIRequest.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public protocol APIRequest {
	var path: String { get }
	var method: HTTPMethod { get }
	var query: [String: String]? { get }
	var headers: [String: String]? { get }
	var body: Data? { get }
	
	func build(with config: NetworkConfiguration) throws -> URLRequest
}
