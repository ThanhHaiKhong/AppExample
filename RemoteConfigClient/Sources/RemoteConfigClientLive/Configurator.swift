//
//  Configurator.swift
//  RemoteConfigClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import RemoteConfigClient
@preconcurrency import FirebaseRemoteConfig

actor Configurator {
    public static let shared = Configurator()
    
    private var cachedEditorChoices: [EditorChoice]? = nil
    private var cachedPhotoSelectionLimitNumber: Int = 20
    
    public init() {
        RemoteConfig.remoteConfig().addOnConfigUpdateListener { configUpdate, error in
            guard error == nil else { return }
            RemoteConfig.remoteConfig().activate { changed, error in
                guard error == nil else { return }
                Task {
                    await self.handleConfigUpdate()
                }
            }
        }
    }
}

// MARK: - Public Methods

extension Configurator {
    public func getEditorChoices() async throws -> [EditorChoice] {
        if let cachedChoices = cachedEditorChoices {
            return cachedChoices
        }
        let fetchedChoices = try await fetchEditorChoices()
        cachedEditorChoices = fetchedChoices
        return fetchedChoices
    }
    
    public func photoSelectionLimitNumber() async throws -> Int {
        if cachedPhotoSelectionLimitNumber != 20 {
            return cachedPhotoSelectionLimitNumber
        }
        
        let fetchedNumber = try await fetchPhotoSelectionLimitNumber()
        cachedPhotoSelectionLimitNumber = fetchedNumber
        return fetchedNumber
    }
}

// MARK: - Supporting Methods

extension Configurator {
    private func handleConfigUpdate() async {
        do {
            let updatedChoices = try await fetchEditorChoices()
            cachedEditorChoices = updatedChoices
            
            let updatedNumber = try await fetchPhotoSelectionLimitNumber()
            cachedPhotoSelectionLimitNumber = updatedNumber
        } catch {
            #if DEBUG
            print("Failed to update editor choices: \(error.localizedDescription)")
            #endif
        }
    }
    
    nonisolated private func fetchEditorChoices() async throws -> [EditorChoice] {
        return try await withCheckedThrowingContinuation { continuation in
            RemoteConfig.remoteConfig().fetchAndActivate { status, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if status == .successFetchedFromRemote {
                    if let editorChoiceJSON = RemoteConfig.remoteConfig().configValue(forKey: "PREF_REMOTE_CONFIG_EDITOR_CHOICES_KEY").jsonValue as? [[String: Any]] {
                        do {
                            let editorChoices = try self.decodeEditorChoices(from: editorChoiceJSON)
                            continuation.resume(returning: editorChoices)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
    
    nonisolated private func decodeEditorChoices(from json: [[String: Any]]) throws -> [EditorChoice] {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let editorChoices = try JSONDecoder().decode([EditorChoice].self, from: jsonData)
        return editorChoices
    }
    
    nonisolated private func fetchPhotoSelectionLimitNumber() async throws -> Int {
        let remoteConfig = RemoteConfig.remoteConfig()
        return try await withCheckedThrowingContinuation { continuation in
            remoteConfig.fetchAndActivate { status, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if status == .successFetchedFromRemote {
                    let number = remoteConfig.configValue(forKey: "PREF_REMOTE_CONFIG_MAX_SELECTABLE_PHOTOS").numberValue
                    continuation.resume(returning: number.intValue)
                }
            }
        }
    }
}
