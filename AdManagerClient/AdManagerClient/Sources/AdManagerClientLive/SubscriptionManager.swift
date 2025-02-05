//
//  SubscriptionManager.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import Foundation
import StoreKit

final actor SubscriptionManager {
    public static let shared = SubscriptionManager()
    
    private let subscriptionKey = "isUserSubscribed"
    
    public func isUserSubscribed() async -> Bool {
        if let cachedValue = UserDefaults.standard.value(forKey: subscriptionKey) as? Bool {
            return cachedValue
        }

        let isSubscribed = await fetchSubscriptionStatus()
        
        UserDefaults.standard.setValue(isSubscribed, forKey: subscriptionKey)
        return isSubscribed
    }
    
    private func fetchSubscriptionStatus() async -> Bool {
        do {
            let products = try await Product.products(for: ["com.app.premium"])
            guard let subscription = products.first else { return false }

            let statuses = try await subscription.subscription?.status
            return statuses?.contains(where: { $0.state == .subscribed }) ?? false
        } catch {
            print("Lỗi kiểm tra subscription: \(error)")
            return false
        }
    }
}
