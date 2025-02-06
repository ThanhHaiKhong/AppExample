// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Foundation

@DependencyClient
public struct AdManagerClient: Sendable {
    public var requestTrackingAuthorizationIfNeeded: @Sendable () async throws -> Void
    public var isUserSubscribed: @Sendable () async throws -> Bool
    public var shouldShowAd: @Sendable (_ adType: AdType, _ rules: [AdRule]) async throws -> Bool
    public var showAd: @Sendable () async throws -> Void
}

extension AdManagerClient {
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
    public var adManagerClient: AdManagerClient {
        get { self[AdManagerClient.self] }
        set { self[AdManagerClient.self] = newValue }
    }
}


extension Effect {
    public static func runWithAdCheck(
        adType: AdManagerClient.AdType,
        rules: [AdManagerClient.AdRule] = [],
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (_ send: Send<Action>) async throws -> Void,
        catch handler: (@Sendable (_ error: any Error, _ send: Send<Action>) async -> Void)? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> Self {
        .run(priority: priority) { send in
            let adManager = DependencyValues._current.adManagerClient
            
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
