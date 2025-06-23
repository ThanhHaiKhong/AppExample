// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros

@DependencyClient
public struct RemoteConfigClient: Sendable {
    public var editorChoices: @Sendable () async throws -> [RemoteConfigClient.EditorChoice]
    public var photoSelectionLimitNumber: @Sendable () async throws -> Int
}
