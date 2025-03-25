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
    private let cacheDuration: TimeInterval = 24 * 60 * 60

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
            throw SubscriptionError.productNotFound
        }
        
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                return transaction
            } else {
                throw SubscriptionError.verificationFailed
            }
        default:
            throw SubscriptionError.transactionFailed
        }
    }
    
    public func restorePurchases() async throws -> [Transaction] {
        var restoredTransactions: [Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            restoredTransactions.append(transaction)
        }
        
        if restoredTransactions.isEmpty {
            throw RestoreError.noPurchasesFound
        }
        
        return restoredTransactions
    }
    
    public func startObserveTransactions() -> AsyncStream<Transaction> {
        AsyncStream { continuation in
            Task {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        continuation.yield(transaction)
                    }
                }
            }
        }
    }
    
    public func verifySubscriptionStatus(productIdentifiers: [String], sharedSecret: String) async throws -> SubscriptionStatus {
        let isSubscribed = await checkSubscriptionWithStoreKit()
        return isSubscribed ? .active : .expired
    }
    
    public func finishUnfinishedTransactions() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
        }
    }
    
    public func getLatestTransaction() async -> Transaction? {
        var latestTransaction: Transaction?
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            let currentExpiration = latestTransaction?.expirationDate ?? Date.distantPast
            let newExpiration = transaction.expirationDate ?? Date.distantPast
            
            if latestTransaction == nil || newExpiration > currentExpiration {
                latestTransaction = transaction
            }
        }
        
        return latestTransaction
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
        
        if product.id == "com.orientpro.photocompress_Weekly" {
            self.localizedDescription = "WEEKLY"
            self.offer = "Flexible"
        } else if product.id == "com.orientpro.photocompress_yearly" {
            self.localizedDescription = "ANNUALLY"
            self.offer = "Best Value"
        } else {
            self.localizedDescription = product.description
            self.offer = product.subscription?.promotionalOffers.description ?? ""
        }
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

public enum SubscriptionError: Error, Sendable {
    case productNotFound
    case transactionFailed
    case verificationFailed
}

enum RestoreError: Error, LocalizedError, Sendable {
    case noPurchasesFound
    
    var errorDescription: String? {
        switch self {
        case .noPurchasesFound:
            return "No previous purchases found. If you believe this is an error, please check your Apple ID."
        }
    }
}
