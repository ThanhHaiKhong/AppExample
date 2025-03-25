//
//  RemoteConfigClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 5/12/24.
//

import ComposableArchitecture
import FirebaseRemoteConfig

@DependencyClient
public struct RemoteConfigClient: Sendable {
    public var editorChoices: @Sendable () async throws -> [EditorChoice]
    public var photoSelectionLimitNumber: @Sendable () async throws -> Int
}

extension RemoteConfigClient: DependencyKey {
    public static var liveValue: RemoteConfigClient {
        let configurator = Configurator()
        return Self(
            editorChoices: configurator.getEditorChoices,
            photoSelectionLimitNumber: configurator.photoSelectionLimitNumber
        )
    }
}

extension RemoteConfigClient: TestDependencyKey {
    public static var testValue: RemoteConfigClient {
        RemoteConfigClient()
    }
    
    public static var previewValue: RemoteConfigClient {
        RemoteConfigClient()
    }
}

extension DependencyValues {
    public var remoteConfigClient: RemoteConfigClient {
        get { self[RemoteConfigClient.self] }
        set { self[RemoteConfigClient.self] = newValue }
    }
}
