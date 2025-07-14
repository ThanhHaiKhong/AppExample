// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros
import Foundation

@DependencyClient
public struct NetworkClient: Sendable {
	public var authenticate: @Sendable (_ request: NetworkClient.AuthRequest) async throws -> NetworkClient.AuthResponse = { _ in
		throw NetworkClient.Error.invalidResponse
	}
	public var send: @Sendable (_ request: NetworkClient.Request) async throws-> NetworkClient.Response = { _ in
		throw NetworkClient.Error.invalidResponse
	}
}

/*
 public var decode: @Sendable (_ data: Data, _ type: Any.Type) throws -> Any = { _, _ in
 throw NetworkClient.Error.invalidResponse
 }
 public var log: @Sendable (_ request: NetworkClient.Request, _ response: NetworkClient.Response) -> Void = { _, _ in }
 public var isConnected: @Sendable () -> Bool = {
 return true
 }
 public var cancelAllRequests: @Sendable () -> Void
 public var buildRequest: @Sendable (_ request: NetworkClient.Request) throws -> URLRequest = { request in
 request.urlRequest
 }
 */
