//
//  Live.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture
import AdManagerClient

extension AdManagerClient: DependencyKey {
    public static let liveValue: AdManagerClient = {
        return AdManagerClient(
            isUserSubscribed: {
                return await SubscriptionManager.shared.isUserSubscribed()
            },
            shouldShowAd: { adType, rules in
                return await AdsManager.shared.shouldShowAd(adType, rules: rules)
            },
            showAd: {
                try await AdsManager.shared.showAd()
            }
        )
    }()
}

extension Array where Element == AdManagerClient.AdRule {
    public func allRulesSatisfied() async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            for rule in self {
                group.addTask {
                    await rule.evaluate()
                }
            }
            
            for await result in group {
                if !result {
                    group.cancelAll()
                    return false
                }
            }
            return true
        }
    }
}
