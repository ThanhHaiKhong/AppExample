//
//  TokenProvider.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

@MainActor
public protocol TokenProvider: AnyObject {
	// The token that is currently being used for authentication. May be cached or request
	func getToken() async throws -> String
	
	// Call to refresh the token if it has expired or is invalid.
	func refreshToken() async throws -> String
}

extension TokenProvider {
	public func authorizationHeader(token: String, type: TokenType = .bearer) -> String {
		"\(type.rawValue) \(token)"
	}
}

public enum TokenType: String {
	case bearer = "Bearer"
	case jwt = "JWT"
	case token = "Token"
}
