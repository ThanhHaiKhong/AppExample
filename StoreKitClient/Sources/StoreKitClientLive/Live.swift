//
//  Live.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 27/3/25.
//

import ComposableArchitecture
import StoreKitClient
import StoreKit

@available(iOSApplicationExtension, unavailable)
@available(iOS 15.0, *)
extension StoreKitClient: DependencyKey {
    public static let liveValue = Self(
        receiptURL: {
            Bundle.main.appStoreReceiptURL
        },
        canMakePayments: {
            AppStore.canMakePayments
        },
        loadProducts: { productIDs in
            do {
                let fetchedProducts = try await StoreKit.Product.products(for: productIDs)
                return fetchedProducts.map { StoreKitClient.Product(rawValue: $0) }
            } catch {
                throw StoreKitError.fetchProductsFailed(productIDs: productIDs, underlyingError: error)
            }
        },
        processUnfinishedConsumables: { @Sendable handler in
            for await result in StoreKit.Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else { continue }
                if transaction.productType == .consumable {
                    let key = "StoreKitClient_delivered_\(transaction.id)"
                    if !UserDefaults.standard.bool(forKey: key) {
                        do {
                            try await handler(StoreKitClient.Transaction(rawValue: transaction))
                            UserDefaults.standard.set(true, forKey: key)
                            await transaction.finish()
                        } catch {
                            #if DEBUG
                            print("🐞 Failed to deliver consumable \(transaction.productID): \(error)")
                            #endif
                            // Don’t finish if delivery fails
                        }
                    }
                }
            }
        },
        observeTransactions: {
            AsyncStream { continuation in
                Task(priority: .background) {
                    for await result in StoreKit.Transaction.updates {
                        switch result {
                            case .verified(let transaction):
                                let wrapped = StoreKitClient.Transaction(rawValue: transaction)
                                let event = transaction.revocationDate != nil
                                ? TransactionEvent.removed(wrapped)
                                : TransactionEvent.updated(wrapped)
                                continuation.yield(event)
                                
                            case .unverified(_, let error):
                                continuation.yield(.verificationFailed(error))
                        }
                    }
                    
                    continuation.onTermination = { @Sendable _ in
                        #if DEBUG
                        print("🏁 Transaction monitoring terminated")
                        #endif
                    }
                }
            }
        },
        requestReview: {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else {
                return
            }
            
            if #available(iOS 16.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        },
        purchase: { productID in
            let products = try await StoreKit.Product.products(for: [productID])
            guard let product = products.first else {
                throw StoreKitError.productNotFound(productID: productID)
            }
            
            let result = try await product.purchase()
            switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                        case .verified(let transaction):
                            return StoreKitClient.Transaction(rawValue: transaction)
                            
                        case .unverified(_, let error):
                            throw StoreKitError.unverifiedTransaction(error)
                    }
                    
                case .userCancelled:
                    throw StoreKitError.userCancelled
                    
                case .pending:
                    throw StoreKitError.purchasePending
                    
                @unknown default:
                    throw StoreKitError.unknownPurchaseResult
            }
        },
        restorePurchases: {
            var restoredTransactions: [StoreKitClient.Transaction] = []
            
            for await result in StoreKit.Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else { continue }
                restoredTransactions.append(StoreKitClient.Transaction(rawValue: transaction))
            }
            
            return restoredTransactions
        }
    )
}

private actor LiveActor {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    nonisolated func receiptURL() -> URL? {
        Bundle.main.appStoreReceiptURL
    }
    
    nonisolated func canMakePayments() -> Bool {
        AppStore.canMakePayments
    }
    
    func loadProducts(for productIDs: Set<String>) async throws -> [StoreKitClient.Product] {
        let storeKitProducts = try await fetchStoreKitProducts(for: productIDs)
        return storeKitProducts.map(StoreKitClient.Product.init)
    }
    
    func processUnfinishedConsumables(handler: @Sendable @escaping (StoreKitClient.Transaction) async throws -> Void) async {
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            guard let transaction = verifiedTransaction(from: entitlement) else { continue }
            if transaction.productType == .consumable {
                await deliverConsumable(transaction: transaction, with: handler)
            }
        }
    }
    
    func observeTransactions() -> AsyncStream<StoreKitClient.TransactionEvent> {
        AsyncStream { continuation in
            Task(priority: .background) {
                for await update in StoreKit.Transaction.updates {
                    continuation.yield(eventFromTransactionUpdate(update))
                }
                continuation.onTermination = { _ in  }
            }
        }
    }
    
    func requestReview() async {
        guard let windowScene = await currentWindowScene() else { return }
        if #available(iOS 16.0, *) {
            await AppStore.requestReview(in: windowScene)
        } else {
            await SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func purchase(productID: String) async throws -> StoreKitClient.Transaction {
        let product = try await fetchSingleProduct(for: productID)
        let purchaseResult = try await product.purchase()
        return try handlePurchaseResult(purchaseResult)
    }
    
    func restorePurchases() async -> [StoreKitClient.Transaction] {
        var restored: [StoreKitClient.Transaction] = []
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = verifiedTransaction(from: entitlement) {
                restored.append(StoreKitClient.Transaction(rawValue: transaction))
            }
        }
        return restored
    }
    
    // MARK: - Private Helpers
    private func fetchStoreKitProducts(for productIDs: Set<String>) async throws -> [StoreKit.Product] {
        do {
            return try await StoreKit.Product.products(for: productIDs)
        } catch {
            throw StoreKitClient.StoreKitError.fetchProductsFailed(productIDs: productIDs, underlyingError: error)
        }
    }
    
    private func fetchSingleProduct(for productID: String) async throws -> StoreKit.Product {
        let products = try await fetchStoreKitProducts(for: [productID])
        guard let product = products.first else {
            throw StoreKitClient.StoreKitError.productNotFound(productID: productID)
        }
        return product
    }
    
    private func verifiedTransaction(from result: VerificationResult<StoreKit.Transaction>) -> StoreKit.Transaction? {
        if case .verified(let transaction) = result { return transaction }
        return nil
    }
    
    private func deliverConsumable(transaction: StoreKit.Transaction, with handler: @Sendable (StoreKitClient.Transaction) async throws -> Void) async {
        let deliveryKey = "StoreKitClient_delivered_\(transaction.id)"
        guard !userDefaults.bool(forKey: deliveryKey) else { return }
        
        do {
            let wrappedTransaction = StoreKitClient.Transaction(rawValue: transaction)
            try await handler(wrappedTransaction)
            userDefaults.set(true, forKey: deliveryKey)
            await transaction.finish()
        } catch {
            logDebug("Failed to deliver consumable \(transaction.productID): \(error)")
        }
    }
    
    private func eventFromTransactionUpdate(_ result: VerificationResult<StoreKit.Transaction>) -> StoreKitClient.TransactionEvent {
        switch result {
            case .verified(let transaction):
                let wrapped = StoreKitClient.Transaction(rawValue: transaction)
                return transaction.revocationDate != nil ? .removed(wrapped) : .updated(wrapped)
            case .unverified(_, let error):
                return .verificationFailed(error)
        }
    }
    
    private func handlePurchaseResult(_ result: StoreKit.Product.PurchaseResult) throws -> StoreKitClient.Transaction {
        switch result {
            case .success(let verificationResult):
                switch verificationResult {
                    case .verified(let transaction):
                        return StoreKitClient.Transaction(rawValue: transaction)
                    case .unverified(_, let error):
                        throw StoreKitClient.StoreKitError.unverifiedTransaction(error)
                }
            case .userCancelled:
                throw StoreKitClient.StoreKitError.userCancelled
            case .pending:
                throw StoreKitClient.StoreKitError.purchasePending
            @unknown default:
                throw StoreKitClient.StoreKitError.unknownPurchaseResult
        }
    }
    
    private func currentWindowScene() async -> UIWindowScene? {
        await UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene
    }
    
    private func logDebug(_ message: String) {
        #if DEBUG
        print("🐞 \(message)")
        #endif
    }
}
