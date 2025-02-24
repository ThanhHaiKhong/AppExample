//
//  InAppPurchaseClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 23/1/25.
//

import ComposableArchitecture
import MobileAdsClientLive
import StoreKit
import Combine

@available(iOS 15.0, *)
@DependencyClient
public struct InAppPurchaseClient: Sendable {
    public var fetchProducts: @Sendable (_ productIdentifiers: [String]) async throws -> [IAPProduct]
    public var purchase: @Sendable (_ productID: String) async throws -> Transaction
    public var restorePurchases: @Sendable () async throws -> [Transaction]
    public var observeTransactions: @Sendable () async throws -> AsyncStream<Transaction>
    public var verifySubscriptionStatus: @Sendable (_ productIdentifiers: [String], _ sharedSecret: String) async throws -> SubscriptionStatus
}

@available(iOS 15.0, *)
extension InAppPurchaseClient: DependencyKey {
    public static let liveValue: InAppPurchaseClient = {
        let subscription = SubscriptionManager.shared
        
        return InAppPurchaseClient(
            fetchProducts: { productIdentifiers in
                return try await subscription.fetchProducts(productIdentifiers: productIdentifiers)
            },
            purchase: { productID in
                return try await subscription.purchase(productID: productID)
            },
            restorePurchases: {
                return try await subscription.restorePurchases()
            },
            observeTransactions: {
                return subscription.observeTransactions()
            },
            verifySubscriptionStatus: { productIdentifiers, sharedSecret in
                return try await subscription.verifySubscriptionStatus(productIdentifiers: productIdentifiers, sharedSecret: sharedSecret)
            }
        )
    }()
}

@available(iOS 15.0, *)
extension InAppPurchaseClient: TestDependencyKey {
    public static var testValue: InAppPurchaseClient {
        InAppPurchaseClient()
    }
}

@available(iOS 15.0, *)
extension DependencyValues {
    public var inAppPurchaseClient: InAppPurchaseClient {
        get { self[InAppPurchaseClient.self] }
        set { self[InAppPurchaseClient.self] = newValue }
    }
}
