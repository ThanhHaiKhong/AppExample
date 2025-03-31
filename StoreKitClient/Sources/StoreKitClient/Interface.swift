// The Swift Programming Language
// https://docs.swift.org/swift-book

import DependenciesMacros
import StoreKit

@DependencyClient
@available(iOS 15.0, *)
public struct StoreKitClient: Sendable {
    public var receiptURL: @Sendable () -> URL?
    public var canMakePayments: @Sendable () -> Bool = { false }
    public var loadProducts: @Sendable (_ productIDs: Set<String>) async throws -> [StoreKitClient.Product]
    public var processUnfinishedConsumables: @Sendable (_ deliverConsumable: @Sendable @escaping (StoreKitClient.Transaction) async throws -> Void) async -> Void
    public var observeTransactions: @Sendable () -> AsyncStream<TransactionEvent> = { .finished }
    public var requestReview: @Sendable () async -> Void
    public var purchase: @Sendable (_ productID: String) async throws -> StoreKitClient.Transaction
    public var restorePurchases: @Sendable () async -> [StoreKitClient.Transaction] = { [] }
}
