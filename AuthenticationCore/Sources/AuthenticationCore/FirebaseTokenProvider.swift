//
//  FirebaseTokenProvider.swift
//  NetworkCore
//
//  Created by Thanh Hai Khong on 10/7/25.
//

@preconcurrency import FirebaseAuth

@MainActor
public final class FirebaseTokenProvider: TokenProvider {
	private var currentToken: String?
	private var expiryDate: Date?
	
	public init() {
		
	}
	
	public func getToken() async throws -> String {
		if let token = currentToken, let expiry = expiryDate, Date() < expiry {
			return token
		}
		
		let result = try await Auth.auth().signInAnonymously()
		let authTokenResult = try await result.user.getIDTokenResult()
		let token = authTokenResult.token
		self.currentToken = token
		self.expiryDate = authTokenResult.expirationDate
		return token
	}
	
	public func refreshToken() async throws -> String {
		guard let user = Auth.auth().currentUser else {
			throw NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"])
		}
		
		let authTokenResult = try await user.getIDTokenResult(forcingRefresh: true)
		let token = authTokenResult.token
		self.currentToken = token
		self.expiryDate = authTokenResult.expirationDate
		return token
	}
}
