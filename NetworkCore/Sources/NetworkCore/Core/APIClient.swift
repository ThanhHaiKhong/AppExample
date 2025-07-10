//
//  APIClient.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public protocol APIClient {
	func send<T: Decodable>(_ request: APIRequest) async throws -> T
}

public final class DefaultAPIClient: APIClient {
	private let session: URLSession
	private let config: NetworkConfiguration
	
	public init(config: NetworkConfiguration, session: URLSession = .shared) {
		self.config = config
		self.session = session
	}
	
	public func send<T: Decodable>(_ request: APIRequest) async throws -> T {
		let urlRequest = try request.build(with: config)
		let (data, response) = try await session.data(for: urlRequest)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkError.invalidResponse
		}
		
		guard 200..<300 ~= httpResponse.statusCode else {
			throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
		}
		
		if T.self == Void.self {
			return () as! T
		}
		
		do {
			return try JSONDecoder().decode(T.self, from: data)
		} catch {
			throw NetworkError.decodingError(error)
		}
	}
}
