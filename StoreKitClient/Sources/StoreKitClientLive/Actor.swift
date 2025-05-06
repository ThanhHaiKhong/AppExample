//
//  StoreKitLiveActor.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 31/3/25.
//

import StoreKitClient
import StoreKit
import UIKit

actor StoreKitLiveActor {
    private let userDefaults: UserDefaults
    private let logger: (String) -> Void
    private var productCache: [String: StoreKit.Product] = [:]
    private var deliveredTransactions: Set<UInt64> = []
    
    init(
        userDefaults: UserDefaults = .standard,
        logger: @escaping (String) -> Void = { message in
            #if DEBUG
            print("🛍️ [STORE_KIT_LIVE_ACTOR]: \(message)")
            #endif
        }
    ) {
        self.userDefaults = userDefaults
        self.logger = logger
    }
    
    nonisolated func receiptURL() -> URL? {
        Bundle.main.appStoreReceiptURL
    }
    
    nonisolated func canMakePayments() -> Bool {
        AppStore.canMakePayments
    }
    
    func loadProducts(for productIDs: Set<String>) async throws -> [StoreKitClient.Product] {
        let uncachedIDs = productIDs.filter { productCache[$0] == nil }
        if !uncachedIDs.isEmpty {
            let fetched = try await fetchStoreKitProducts(for: uncachedIDs)
            for product in fetched {
                productCache[product.id] = product
            }
        }
        return productIDs.compactMap { productCache[$0] }.map(StoreKitClient.Product.init)
    }
    
    func processUnfinishedConsumables(handler: @Sendable @escaping (StoreKitClient.Transaction) async throws -> Void) async {
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            guard let transaction = verifiedTransaction(from: entitlement) else { continue }
            if transaction.productType == .consumable {
                await deliverConsumable(transaction: transaction, with: handler)
            }
        }
    }
    
    nonisolated func observeTransactions() -> AsyncStream<StoreKitClient.TransactionEvent> {
        AsyncStream { [weak self] continuation in
            guard let self else { continuation.finish(); return }
            Task(priority: .background) {
                for await update in StoreKit.Transaction.updates {
                    continuation.yield(await self.handleTransactionUpdate(update))
                }
                
                continuation.onTermination = { _ in
                    
                }
            }
        }
    }
    
    func requestReview() async {
        guard let windowScene = await currentWindowScene() else {
            logger("No window scene found for review request")
            return
        }
        if #available(iOS 16.0, *) {
            await AppStore.requestReview(in: windowScene)
        } else {
            await SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func purchase(productID: String) async throws -> StoreKitClient.Transaction {
        let product = try await fetchOrGetCachedProduct(for: productID)
        let purchaseResult = try await product.purchase()
        let transaction = try handlePurchaseResult(purchaseResult)
        trackTransaction(transaction)
        return transaction
    }
    
    func restorePurchases() async -> [StoreKitClient.Transaction] {
        var restored: [StoreKitClient.Transaction] = []
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            guard let transaction = verifiedTransaction(from: entitlement) else { continue }
            let wrapped = StoreKitClient.Transaction(rawValue: transaction)
            trackTransaction(wrapped)
            restored.append(wrapped)
        }
        logger("Restored \(restored.count) transactions")
        return restored
    }
    
    func getLatestTransaction() async -> StoreKitClient.Transaction? {
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
        
        return StoreKitClient.Transaction(rawValue: latestTransaction)
    }
    
    // MARK: - Private Helpers
    
    private func fetchStoreKitProducts(for productIDs: Set<String>) async throws -> [StoreKit.Product] {
        do {
            logger("Fetching products: \(productIDs)")
            return try await StoreKit.Product.products(for: productIDs)
        } catch {
            logger("Failed to fetch products: \(error)")
            throw StoreKitClient.StoreClientError.fetchProductsFailed(productIDs: productIDs, underlyingError: error)
        }
    }
    
    private func fetchOrGetCachedProduct(for productID: String) async throws -> StoreKit.Product {
        if let cached = productCache[productID] {
            logger("Using cached product: \(productID)")
            return cached
        }
        let product = try await fetchSingleProduct(for: productID)
        productCache[productID] = product
        return product
    }
    
    private func fetchSingleProduct(for productID: String) async throws -> StoreKit.Product {
        let products = try await fetchStoreKitProducts(for: [productID])
        guard let product = products.first else {
            throw StoreKitClient.StoreClientError.productNotFound(productID: productID)
        }
        return product
    }
    
    private func verifiedTransaction(from result: VerificationResult<StoreKit.Transaction>) -> StoreKit.Transaction? {
        if case .verified(let transaction) = result { return transaction }
        return nil
    }
    
    private func deliverConsumable(transaction: StoreKit.Transaction, with handler: @Sendable (StoreKitClient.Transaction) async throws -> Void) async {
        let deliveryKey = "StoreKitClient_delivered_\(transaction.id)"
        guard !userDefaults.bool(forKey: deliveryKey) else {
            logger("Transaction \(transaction.id) already delivered")
            return
        }
        
        do {
            let wrapped = StoreKitClient.Transaction(rawValue: transaction)
            try await handler(wrapped)
            userDefaults.set(true, forKey: deliveryKey)
            deliveredTransactions.insert(transaction.id)
            await transaction.finish()
            logger("Delivered consumable \(transaction.productID)")
        } catch {
            logger("Failed to deliver consumable \(transaction.productID): \(error)")
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<StoreKit.Transaction>) async -> StoreKitClient.TransactionEvent {
        switch result {
        case .verified(let transaction):
            let wrapped = StoreKitClient.Transaction(rawValue: transaction)
            trackTransaction(wrapped)
            return transaction.revocationDate != nil ? .removed(wrapped) : .updated(wrapped)
        case .unverified(_, let error):
            logger("Transaction verification failed: \(error)")
            return .verificationFailed(error)
        }
    }
    
    private func handlePurchaseResult(_ result: StoreKit.Product.PurchaseResult) throws -> StoreKitClient.Transaction {
        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .verified(let transaction):
                logger("Purchase succeeded for \(transaction.productID)")
                return StoreKitClient.Transaction(rawValue: transaction)
            case .unverified(_, let error):
                    throw StoreKitClient.StoreClientError.unverifiedTransaction(error)
            }
        case .userCancelled:
                throw StoreKitClient.StoreClientError.userCancelled
        case .pending:
                throw StoreKitClient.StoreClientError.purchasePending
        @unknown default:
                throw StoreKitClient.StoreClientError.unknownPurchaseResult
        }
    }
    
    private func trackTransaction(_ transaction: StoreKitClient.Transaction) {
        if transaction.productType == .consumable {
            deliveredTransactions.insert(transaction.id)
        }
    }
    
    private func currentWindowScene() async -> UIWindowScene? {
        await UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
    }
}
