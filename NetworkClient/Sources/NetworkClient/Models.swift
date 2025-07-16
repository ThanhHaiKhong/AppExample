//
//  Models.swift
//  NetworkClient
//
//  Created by Thanh Hai Khong on 11/7/25.
//

import Foundation

// MARK: - Request

extension NetworkClient {
	public struct Request: Sendable {
		public var endpoint: Endpoint
		public var payload: Payload
		public var configuration: Configuration
		
		public init(
			endpoint: Endpoint,
			payload: Payload = .empty,
			configuration: Configuration
		) {
			self.endpoint = endpoint
			self.payload = payload
			self.configuration = configuration
		}
	}
}

// MARK: - Request.URLRequest

extension NetworkClient.Request {
	public var urlRequest: URLRequest {
		var url = configuration.baseURL.appendingPathComponent(endpoint.path)
		if let query = endpoint.query {
			var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
			components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
			if let newURL = components?.url {
				url = newURL
			}
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue
		request.httpBody = payload.body
		
		configuration.defaultHeaders.forEach {
			request.setValue($0.value, forHTTPHeaderField: $0.key)
		}
		
		payload.headers?.forEach {
			request.setValue($0.value, forHTTPHeaderField: $0.key)
		}
		
		return request
	}
}

// MARK: - Request.HTTPMethod

extension NetworkClient.Request {
	public enum HTTPMethod: String, Sendable {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
		case patch = "PATCH"
	}
}

// MARK: - Request.Configuration

extension NetworkClient.Request {
	public struct Configuration: Sendable {
		public let baseURL: URL
		public let defaultHeaders: [String: String]
		
		public init(
			baseURL: URL,
			defaultHeaders: [String: String] = [:]
		) {
			self.baseURL = baseURL
			self.defaultHeaders = defaultHeaders
		}
		
		
		public static let `default` = Configuration(
			baseURL: URL(string: "https://api.l7mobile.com")!,
			defaultHeaders: [
				"Content-Type": "application/json"
			]
		)
	}
}

// MARK: - Request.Endpoint

extension NetworkClient.Request {
	public struct Endpoint: Sendable {
		public let path: String
		public let method: HTTPMethod
		public let query: [String: String]?
		
		public init(
			path: String,
			method: HTTPMethod = .get,
			query: [String: String]? = nil
		) {
			self.path = path
			self.method = method
			self.query = query
		}
	}
}

// MARK: - Request.Payload

extension NetworkClient.Request {
	public struct Payload: Sendable {
		public let headers: [String: String]?
		public let body: Data?
		
		public init(
			headers: [String: String]? = nil,
			body: Data? = nil
		) {
			self.headers = headers
			self.body = body
		}
		
		public static let empty = Payload()
	}
}

// MARK: - AuthRequest

extension NetworkClient {
	public struct AuthRequest: Sendable {
		public let kind: Kind
		
		public init(kind: Kind) {
			self.kind = kind
		}
	}
}

extension NetworkClient.AuthRequest {
	public enum Kind: Sendable {
		case login(username: String, password: String)
		case register(username: String, password: String, email: String?)
		case refresh(token: String)
		case thirdParty(provider: Provider)  // e.g., Google, Facebook, Apple
		case firebase(token: String, expiry: Int, options: [String: String]?)
		
		public struct Provider: Sendable {
			public let name: String
			public let token: String
			
			public init(name: String, token: String) {
				self.name = name
				self.token = token
			}
		}
	}
}

extension NetworkClient.AuthRequest {
	public var request: NetworkClient.Request {
		switch kind {
		case .login(let username, let password):
			let endpoint = NetworkClient.Request.Endpoint(path: "/auth/login", method: .post)
			let payload = NetworkClient.Request.Payload(
				headers: ["Content-Type": "application/json"],
				body: try? JSONEncoder().encode(["username": username, "password": password])
			)
			return NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
			
		case .register(let username, let password, let email):
			let endpoint = NetworkClient.Request.Endpoint(path: "/auth/register", method: .post)
			let payload = NetworkClient.Request.Payload(
				headers: ["Content-Type": "application/json"],
				body: try? JSONEncoder().encode(["username": username, "password": password, "email": email])
			)
			return NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
			
		case .refresh(let token):
			let endpoint = NetworkClient.Request.Endpoint(path: "/auth/refresh", method: .post)
			let payload = NetworkClient.Request.Payload(
				headers: ["Content-Type": "application/json"],
				body: try? JSONEncoder().encode(["token": token])
			)
			return NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
			
		case .thirdParty(let provider):
			let endpoint = NetworkClient.Request.Endpoint(path: "/auth/\(provider.name)", method: .post)
			let payload = NetworkClient.Request.Payload(
				headers: ["Content-Type": "application/json"],
				body: try? JSONEncoder().encode(["token": provider.token])
			)
			return NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
			
		case .firebase(let token, let expiry, let options):
			let endpoint = NetworkClient.Request.Endpoint(path: "/sidecar/firebase/auth/token", method: .post)
			struct FirebasePayload: Encodable {
				let token: String
				let token_expiry: Int
				let options: [String: String]?
			}
			let payloadData = FirebasePayload(token: token, token_expiry: expiry, options: options)
			let payload = NetworkClient.Request.Payload(
				headers: ["Content-Type": "application/json"],
				body: try? JSONEncoder().encode(payloadData)
			)
			return NetworkClient.Request(endpoint: endpoint, payload: payload, configuration: .default)
		}
	}
}

// MARK: - Request

extension NetworkClient {
	public struct Response: Sendable {
		public let metadata: Metadata
		public let rawData: Data?
		
		public init(metadata: Metadata, rawData: Data?) {
			self.metadata = metadata
			self.rawData = rawData
		}
	}
}

// MARK: - Response.Metadata

extension NetworkClient.Response {
	public struct Metadata: Sendable {
		public let status: Bool
		public let message: String?
		public let code: Int?
		public let timestamp: Date?
		
		public init(
			status: Bool,
			message: String? = nil,
			code: Int? = nil,
			timestamp: Date? = nil
		) {
			self.status = status
			self.message = message
			self.code = code
			self.timestamp = timestamp
		}
	}
}

// MARK: - AuthResponse

extension NetworkClient {
	public struct AuthResponse: Decodable, Sendable {
		public let token: Token
		
		public init(token: Token) {
			self.token = token
		}
	}
}

extension NetworkClient.AuthResponse {
	public struct Token: Decodable, Sendable {
		public let accessToken: String
		public let refreshToken: String
		public let created: Int
		public let expiry: Int
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case refreshToken = "refresh_token"
			case created
			case expiry
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.accessToken = try container.decode(String.self, forKey: .accessToken)
			self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
			
			// Smart convert: String or Int to Int
			if let createdInt = try? container.decode(Int.self, forKey: .created) {
				self.created = createdInt
			} else if let createdStr = try? container.decode(String.self, forKey: .created),
					  let createdInt = Int(createdStr) {
				self.created = createdInt
			} else {
				throw DecodingError.dataCorruptedError(forKey: .created, in: container, debugDescription: "Invalid created format")
			}
			
			if let expiryInt = try? container.decode(Int.self, forKey: .expiry) {
				self.expiry = expiryInt
			} else if let expiryStr = try? container.decode(String.self, forKey: .expiry),
					  let expiryInt = Int(expiryStr) {
				self.expiry = expiryInt
			} else {
				throw DecodingError.dataCorruptedError(forKey: .expiry, in: container, debugDescription: "Invalid expiry format")
			}
		}
	}
}

extension NetworkClient.AuthResponse.Token {
	public var createdDate: Date {
		return Date(timeIntervalSince1970: TimeInterval(created))
	}
	
	public var expiryDate: Date {
		return Date(timeIntervalSince1970: TimeInterval(expiry))
	}
	
	public var isValid: Bool {
		let now = Date()
		return now >= createdDate && now <= expiryDate
	}
}

// MARK: - Error

extension NetworkClient {
	public enum `Error`: Swift.Error {
		case invalidResponse
		case serverError(statusCode: Int, data: Data?)
		case decodingError(Swift.Error)
		case authenticationError(Swift.Error)
		case unknown(Swift.Error)
	}
}

extension NetworkClient.Error: CustomStringConvertible {
	public var description: String {
		switch self {
		case .invalidResponse:
			return "Invalid response from server."
		case .serverError(let statusCode, let data):
			let dataDescription = data.map { String(data: $0, encoding: .utf8) ?? "No data" } ?? "No data"
			return "Server error with status code \(statusCode): \(dataDescription)"
		case .decodingError(let error):
			return "Decoding error: \(error.localizedDescription)"
		case .authenticationError(let error):
			return "Authentication error: \(error.localizedDescription)"
		case .unknown(let error):
			return "Unknown error: \(error.localizedDescription)"
		}
	}
}
