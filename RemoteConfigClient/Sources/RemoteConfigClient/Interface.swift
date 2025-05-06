// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture

@DependencyClient
public struct RemoteConfigClient: Sendable {
    public var editorChoices: @Sendable () async throws -> [EditorChoice]
    public var photoSelectionLimitNumber: @Sendable () async throws -> Int
}

extension DependencyValues {
    public var remoteConfigClient: RemoteConfigClient {
        get { self[RemoteConfigClient.self] }
        set { self[RemoteConfigClient.self] = newValue }
    }
}
