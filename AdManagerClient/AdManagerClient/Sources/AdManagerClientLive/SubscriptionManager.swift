//
//  SubscriptionManager.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import Foundation
import StoreKit

public final actor SubscriptionManager {
    public static let shared = SubscriptionManager()
    
    private let subscriptionKey = "isUserSubscribed"
    private let lastCheckedKey = "lastCheckedSubscription"
    private let cacheDuration: TimeInterval = 24 * 60 * 60  // Cache trong 24 giờ

    private init() {}
}

// MARK: - Public Methods

extension SubscriptionManager {
    public func isUserSubscribed() async -> Bool {
        if let cachedStatus = getCachedSubscriptionStatus(), !isCacheExpired() {
            return cachedStatus
        }
        
        let isSubscribed = await checkSubscriptionWithStoreKit()
        cacheSubscriptionStatus(isSubscribed)
        return isSubscribed
    }
}

// MARK: - Private Methods

extension SubscriptionManager {
    private func checkSubscriptionWithStoreKit() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if (transaction.productType == .autoRenewable || transaction.productType == .nonRenewable),
                   let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {
                    return true
                }
            }
        }
        return false
    }

    private func cacheSubscriptionStatus(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: subscriptionKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckedKey)
    }

    private func getCachedSubscriptionStatus() -> Bool? {
        return UserDefaults.standard.value(forKey: subscriptionKey) as? Bool
    }

    private func isCacheExpired() -> Bool {
        let lastChecked = UserDefaults.standard.double(forKey: lastCheckedKey)
        let currentTime = Date().timeIntervalSince1970
        return currentTime - lastChecked > cacheDuration
    }
}
