//
//  DefaultTokenProvider.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

import Foundation

public final class DefaultTokenProvider: TokenProvider {
	private let tokenStorage: TokenStorage
	private let tokenGenerator: () async throws -> String
	private let tokenRefresher: () async throws -> String
	private var expiryDate: Date?
	private let expirationInterval: TimeInterval?
	
	public init(
		storage: TokenStorage = InMemoryTokenStorage(),
		generator: @escaping () async throws -> String,
		refresher: @escaping () async throws -> String,
		expirationInterval: TimeInterval? = 3600
	) {
		self.tokenStorage = storage
		self.tokenGenerator = generator
		self.tokenRefresher = refresher
		self.expirationInterval = expirationInterval
	}
	
	public func getToken() async throws -> String {
		if let token = tokenStorage.read(), !token.isEmpty,
		   let expiry = expiryDate, Date() < expiry {
			return token
		}
		let newToken = try await tokenGenerator()
		tokenStorage.save(token: newToken)
		if let interval = expirationInterval {
			self.expiryDate = Date().addingTimeInterval(interval)
		}
		return newToken
	}
	
	public func refreshToken() async throws -> String {
		let newToken = try await tokenRefresher()
		tokenStorage.save(token: newToken)
		if let interval = expirationInterval {
			self.expiryDate = Date().addingTimeInterval(interval)
		}
		return newToken
	}
}
