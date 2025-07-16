//
//  Actor.swift
//  NetworkClient
//
//  Created by Thanh Hai Khong on 11/7/25.
//

import Foundation
import NetworkClient

public actor NetworkActor {
	
	private let apiClient = APIClient()
	
	public init() { }
	
	public func authenticate(_ authRequest: NetworkClient.AuthRequest) async throws -> NetworkClient.AuthResponse {
		try await apiClient.authenticate(authRequest)
	}
	
	public func send(_ request: NetworkClient.Request) async throws -> NetworkClient.Response {
		try await apiClient.send(request)
	}
}

private final class APIClient: @unchecked Sendable {
	
	private let session: URLSession = .shared
	private var authResponse: NetworkClient.AuthResponse?
	
	public init() {}
	
	public func authenticate(_ authRequest: NetworkClient.AuthRequest) async throws -> NetworkClient.AuthResponse {
		if let existingResponse = authResponse {
			if existingResponse.isValid {
				return existingResponse
			} else {
				authResponse = nil
			}
		}
		
		let urlRequest = authRequest.request.urlRequest
		let (data, response) = try await session.data(for: urlRequest)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkClient.Error.invalidResponse
		}
		
		guard 200..<300 ~= httpResponse.statusCode else {
			throw NetworkClient.Error.serverError(statusCode: httpResponse.statusCode, data: data)
		}
		
		do {
			let response = try JSONDecoder().decode(NetworkClient.AuthResponse.self, from: data)
			self.authResponse = response
			return response
		} catch {
			throw NetworkClient.Error.decodingError(error)
		}
	}
	
	public func send(_ request: NetworkClient.Request) async throws -> NetworkClient.Response {
		let urlRequest = request.urlRequest
		let (data, response) = try await session.data(for: urlRequest)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkClient.Error.invalidResponse
		}
		
		guard 200..<300 ~= httpResponse.statusCode else {
			throw NetworkClient.Error.serverError(statusCode: httpResponse.statusCode, data: data)
		}
		
		var message: String? = nil
		if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
			message = object["message"] as? String
		}
		
		let metadata = NetworkClient.Response.Metadata(
			status: (200..<300).contains(httpResponse.statusCode),
			message: message,
			code: httpResponse.statusCode,
			timestamp: Date()
		)
		
		return NetworkClient.Response(metadata: metadata, rawData: data)
	}
}

extension JSONDecoder.DateDecodingStrategy {
	public static var rfc3339Flexible: JSONDecoder.DateDecodingStrategy {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [
			.withInternetDateTime,
			.withFractionalSeconds
		]
		return .custom { decoder in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)
			
			if let date = formatter.date(from: dateStr) {
				return date
			} else {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid RFC3339 date: \(dateStr)")
			}
		}
	}
}
