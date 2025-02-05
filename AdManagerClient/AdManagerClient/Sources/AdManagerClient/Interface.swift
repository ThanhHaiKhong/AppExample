// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture

@DependencyClient
public struct AdManagerClient: Sendable {
    public var isUserSubscribed: @Sendable () async throws -> Bool
    public var shouldShowAd: @Sendable (_ adType: AdType, _ rules: [AdRule]) async throws -> Bool
    public var showAd: @Sendable () async throws -> Void
    
    public struct AdRule: Sendable {
        public let name: String
        public let priority: Int
        public let evaluate: @Sendable () async -> Bool
        
        public init(name: String, priority: Int = 0, evaluate: @escaping @Sendable () async -> Bool) {
            self.name = name
            self.priority = priority
            self.evaluate = evaluate
        }
    }

    public enum AdType: Sendable, Equatable {
        case appOpen(AdUnitID)
        case interstitial(AdUnitID)
        case rewarded(AdUnitID)
        
        public typealias AdUnitID = String
    }
}

extension DependencyValues {
    public var adManagerClient: AdManagerClient {
        get { self[AdManagerClient.self] }
        set { self[AdManagerClient.self] = newValue }
    }
}


extension Effect {
    public static func performActionWithAd(
        _ adType: AdManagerClient.AdType,
        _ rules: [AdManagerClient.AdRule] = [],
        _ action: @escaping @Sendable () -> Void
    ) -> Self {
        .run { _ in
            let adManager = DependencyValues._current.adManagerClient
            
            if try await adManager.isUserSubscribed() {
                action()
            } else if try await adManager.shouldShowAd(adType, rules) {
                try await adManager.showAd()
                action()
            } else {
                action()
            }
        } catch: { error, send in
            print("Error while showing ad: \(error)")
            action()
        }
    }
}

