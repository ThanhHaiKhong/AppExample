// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import TCAInitializableReducer
import Foundation

@DependencyClient
public struct MobileAdsClient: Sendable {
    public var requestTrackingAuthorizationIfNeeded: @Sendable () async throws -> Void
    public var isUserSubscribed: @Sendable () async throws -> Bool
    public var shouldShowAd: @Sendable (_ adType: AdType, _ rules: [AdRule]) async throws -> Bool
    public var showAd: @Sendable () async throws -> Void
}

extension MobileAdsClient {
    public struct AdRule: Sendable, Identifiable, Equatable, CustomStringConvertible {
        public let id: String = UUID().uuidString
        public let name: String
        public let priority: Int
        public let evaluate: @Sendable () async -> Bool
        
        public init(name: String, priority: Int = 0, evaluate: @escaping @Sendable () async -> Bool) {
            self.name = name
            self.priority = priority
            self.evaluate = evaluate
        }
        
        public static func == (lhs: AdRule, rhs: AdRule) -> Bool {
            lhs.id == rhs.id
        }
        
        public var description: String {
            """
            AdRule {
                id: \(id)
                name: "\(name)"
                priority: \(priority)
            }
            """
        }
        
        public func detailedDescription() async -> String {
            let result = await evaluate()
            return """
            AdRule {
                id: \(id)
                name: "\(name)"
                priority: \(priority)
                evaluate result: \(result ? "✅ Passed" : "❌ Failed")
            }
            """
        }
    }
    
    public enum AdType: Sendable, Equatable, CustomStringConvertible {
        case appOpen(AdUnitID)
        case interstitial(AdUnitID)
        case rewarded(AdUnitID)
        
        public typealias AdUnitID = String
        
        public var description: String {
            switch self {
            case .appOpen: return "APP OPEN"
            case .interstitial: return "INTERSTITIAL"
            case .rewarded: return "REWARDED"
            }
        }
    }
    
    public enum AdError: Error, Sendable, Equatable, CustomStringConvertible {
        case adNotReady
        
        public var description: String {
            switch self {
            case .adNotReady: return "The ad is not ready to be shown."
            }
        }
    }
}

extension DependencyValues {
    public var mobileAdsClient: MobileAdsClient {
        get { self[MobileAdsClient.self] }
        set { self[MobileAdsClient.self] = newValue }
    }
}

extension Effect {
    public static func runWithAdCheck(
        adType: MobileAdsClient.AdType,
        rules: [MobileAdsClient.AdRule] = [],
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (_ send: Send<Action>) async throws -> Void,
        catch handler: (@Sendable (_ error: any Error, _ send: Send<Action>) async -> Void)? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> Self {
        .run(priority: priority) { send in
            let adManager = DependencyValues._current.mobileAdsClient
            
            if try await adManager.isUserSubscribed() {
                try await operation(send)
            } else if try await adManager.shouldShowAd(adType, rules) {
                try await adManager.requestTrackingAuthorizationIfNeeded()
                try await adManager.showAd()
                try await operation(send)
            } else {
                try await operation(send)
            }
        } catch: { error, send in
            guard let handler else {
                reportIssue(
                """
                An "Effect.runWithAdCheck" returned from "\(fileID):\(line)" threw an unhandled error. …
                
                All non-cancellation errors must be explicitly handled via the "catch" parameter \
                on "Effect.runWithAdCheck", or via a "do" block.
                """,
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
                )
                return
            }
            await handler(error, send)
        }
    }
}

public protocol ExtraStateConstraints: Equatable, Sendable {
    
}

public protocol ExtraActionConstraints: Equatable, Sendable {
    
}
/*
@Reducer
public struct ItemWithAdReducer<Content: TCAInitializableReducer, Ad: TCAInitializableReducer>: Sendable
where Content.State: Identifiable, Ad.State: Identifiable {

    @ObservableState
    public enum State: Identifiable {
        case content(Content.State)
        case ad(Ad.State)
        
        public var id: AnyHashable {
            switch self {
            case .content(let contentState):
                return contentState.id
            case .ad(let adState):
                return adState.id
            }
        }
    }
    
    public enum Action {
        case content(Content.Action)
        case ad(Ad.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.content, action: \.content) {
            Content()
        }
        
        Scope(state: \.ad, action: \.ad) {
            Ad()
        }
    }
    
    public init() {}
}

extension ItemWithAdReducer.State: Equatable where Content.State: ExtraStateConstraints, Ad.State: ExtraStateConstraints {
    
}

extension ItemWithAdReducer.Action: Equatable where Content.Action: ExtraActionConstraints, Ad.Action: ExtraActionConstraints {
    
}

extension ItemWithAdReducer.State: Sendable where Content.State: ExtraStateConstraints, Ad.State: ExtraStateConstraints {
    
}

extension ItemWithAdReducer.Action: Sendable where Content.Action: ExtraActionConstraints, Ad.Action: ExtraActionConstraints {
    
}
*/

@Reducer
public struct ItemWithAdReducer<Content: TCAInitializableReducer, Ad: TCAInitializableReducer>: Sendable
where Content.State: Identifiable & Sendable & Equatable,
      Ad.State: Identifiable & Sendable & Equatable,
      Content.Action: Sendable & Equatable,
      Ad.Action: Sendable & Equatable {
    
    @ObservableState
    public enum State: Identifiable, Equatable {
        case content(Content.State)
        case ad(Ad.State)
        
        public var id: AnyHashable {
            switch self {
            case .content(let contentState):
                return contentState.id

            case .ad(let adState):
                return adState.id
            }
        }
    }
    
    public enum Action: Equatable {
        case content(Content.Action)
        case ad(Ad.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.content, action: \.content) {
            Content()
        }
        
        Scope(state: \.ad, action: \.ad) {
            Ad()
        }
    }
    
    public init() {}
}
