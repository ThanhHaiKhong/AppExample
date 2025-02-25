//
//  SubscriptionManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture
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
    
    public func fetchProducts(productIdentifiers: [String]) async throws -> [IAPProduct] {
        let products = try await Product.products(for: Set(productIdentifiers))
        return products.map { IAPProduct(product: $0) }
    }
    
    public func purchase(productID: String) async throws -> Transaction {
        guard let product = try await Product.products(for: [productID]).first else {
            throw NSError(domain: "SubscriptionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
        }
        
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                return transaction
            } else {
                throw NSError(domain: "SubscriptionManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"])
            }
        default:
            throw NSError(domain: "SubscriptionManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Purchase failed"])
        }
    }
    
    public func restorePurchases() async throws -> [Transaction] {
        var restoredTransactions: [Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                restoredTransactions.append(transaction)
            }
        }
        
        return restoredTransactions
    }
    
    public func observeTransactions() -> AsyncStream<Transaction> {
        AsyncStream { continuation in
            Task {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        continuation.yield(transaction)
                    }
                }
                continuation.finish()
            }
        }
    }
    
    public func verifySubscriptionStatus(productIdentifiers: [String], sharedSecret: String) async throws -> SubscriptionStatus {
        let isSubscribed = await checkSubscriptionWithStoreKit()
        return isSubscribed ? .active : .expired
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

@available(iOS 15.0, *)
public struct IAPProduct: Identifiable, Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
    public let id: String
    public let displayName: String
    public let price: Decimal
    public let displayPrice: String
    public let localizedDescription: String
    public let offer: String
    
    public init(product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.price = product.price
        self.displayPrice = product.displayPrice
        self.localizedDescription = product.id == "com.orientpro.photocompress_Weekly" ? "WEEKLY" : "ANNUALLY"
        self.offer = product.id == "com.orientpro.photocompress_Weekly" ? "Flexible" : "Best Value"
    }
    
    public static func == (lhs: IAPProduct, rhs: IAPProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    public var description: String {
        """
        IAPProduct:
        - ID: \(id)
        - Title: \(displayName)
        - Price: \(displayPrice)
        - Description: \(localizedDescription)
        """
    }
}

public enum PurchaseResult {
    case success(SKPaymentTransaction)
    case failure(Error)
    case cancelled
}

public enum SubscriptionStatus: Sendable, Equatable {
    case active
    case expired
    case notPurchased
}
