// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros
import FirebaseAuth

@DependencyClient
public struct FirebaseAuthClient: Sendable {
	public var currentUser: @Sendable () async -> FirebaseAuth.User? = { nil }
	public var isAuthenticated: @Sendable () async -> Bool = { false }
	public var fetchUserIDToken: @Sendable () async throws -> String = { "" }
	public var fetchUserRefreshToken: @Sendable () async throws -> String = { "" }
	public var fetchUserAccessToken: @Sendable () async throws -> String = { "" }
}
