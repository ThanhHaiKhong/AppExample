//
//  Effect+Extensions.swift
//  Example
//
//  Created by Thanh Hai Khong on 6/2/25.
//

import ComposableArchitecture
import AdManagerClient

/*
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
                An "Effect.run" returned from "\(fileID):\(line)" threw an unhandled error. …
                
                All non-cancellation errors must be explicitly handled via the "catch" parameter \
                on "Effect.run", or via a "do" block.
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
*/
