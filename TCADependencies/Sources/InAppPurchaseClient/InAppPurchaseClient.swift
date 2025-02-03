//
//  InAppPurchaseClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 23/1/25.
//

import ComposableArchitecture
import StoreKit
import Combine

@DependencyClient
public struct InAppPurchaseClient: Sendable {
    public var fetchProducts: @Sendable (_ productIdentifiers: [String]) async throws -> [SKProduct]
    public var purchase: @Sendable (_ product: SKProduct) async throws -> PurchaseResult
    public var restorePurchases: @Sendable () async throws -> [SKPaymentTransaction]
    public var observeTransactions: @Sendable () async throws -> AsyncStream<SKPaymentTransaction>
    public var verifySubscriptionStatus: @Sendable (_ productIdentifiers: [String], _ sharedSecret: String) async throws -> SubscriptionStatus
}

extension InAppPurchaseClient: DependencyKey {
    public static let liveValue: InAppPurchaseClient = {
        let manager = InAppPurchaseManager()
        return InAppPurchaseClient(
            fetchProducts: { productIdentifiers in
                return try await manager.fetchProducts(productIdentifiers: productIdentifiers)
            },
            purchase: { product in
                return try await manager.purchase(product: product)
            },
            restorePurchases: {
                return try await manager.restorePurchases()
            },
            observeTransactions: {
                return manager.observeTransactions()
            },
            verifySubscriptionStatus: { productIdentifiers, sharedSecret in
                return await manager.verifySubscriptionStatus(for: productIdentifiers, sharedSecret: sharedSecret)
            }
        )
    }()
}

extension InAppPurchaseClient: TestDependencyKey {
    public static var testValue: InAppPurchaseClient {
        InAppPurchaseClient()
    }
}

extension DependencyValues {
    public var inAppPurchaseClient: InAppPurchaseClient {
        get { self[InAppPurchaseClient.self] }
        set { self[InAppPurchaseClient.self] = newValue }
    }
}

public enum PurchaseResult {
    case success(SKPaymentTransaction)
    case failure(Error)
    case cancelled
}

public enum SubscriptionStatus {
    case active
    case expired
    case notPurchased
}

private final class InAppPurchaseManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate, @unchecked Sendable {
    private var productRequest: SKProductsRequest?
    private var continuation: CheckedContinuation<[SKProduct], Error>?
    private let transactionSubject = PassthroughSubject<SKPaymentTransaction, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    public func fetchProducts(productIdentifiers: [String]) async throws -> [SKProduct] {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
            productRequest?.delegate = self
            productRequest?.start()
        }
    }

    public func purchase(product: SKProduct) async throws -> PurchaseResult {
        try await withCheckedThrowingContinuation { continuation in
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            transactionSubject
                .first { $0.payment.productIdentifier == product.productIdentifier }
                .sink { transaction in
                    switch transaction.transactionState {
                    case .purchased:
                        continuation.resume(returning: .success(transaction))
                    case .failed:
                        continuation.resume(returning: .failure(transaction.error ?? NSError(domain: "PurchaseError", code: -1)))
                    case .restored:
                        continuation.resume(returning: .success(transaction))
                    default:
                        continuation.resume(returning: .cancelled)
                    }
                }
                .store(in: &cancellables)
        }
    }

    public func restorePurchases() async throws -> [SKPaymentTransaction] {
        try await withCheckedThrowingContinuation { continuation in
            SKPaymentQueue.default().restoreCompletedTransactions()
            transactionSubject
                .collect()
                .sink { transactions in
                    continuation.resume(returning: transactions)
                }
                .store(in: &cancellables)
        }
    }

    public func observeTransactions() -> AsyncStream<SKPaymentTransaction> {
        AsyncStream { continuation in
            transactionSubject
                .sink { transaction in
                    continuation.yield(transaction)
                }
                .store(in: &cancellables)
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            transactionSubject.send(transaction)
        }
    }
    
    public func verifySubscriptionStatus(for productIdentifiers: [String], sharedSecret: String) async -> SubscriptionStatus {
        let receiptURL = Bundle.main.appStoreReceiptURL

        guard let receiptURL, let receiptData = try? Data(contentsOf: receiptURL) else {
            return .notPurchased
        }

        do {
            let receiptInfo = try await verifyReceipt(with: receiptData, sharedSecret: sharedSecret)
            let activeSubscriptions = parseReceipt(receiptInfo, for: productIdentifiers)

            if activeSubscriptions.isEmpty {
                return .expired
            } else {
                return .active
            }
        } catch {
            print("Failed to verify receipt: \(error)")
            return .notPurchased
        }
    }

    private func verifyReceipt(with receiptData: Data, sharedSecret: String) async throws -> [String: Any] {
        let receiptBase64 = receiptData.base64EncodedString()
        let requestBody = [
            "receipt-data": receiptBase64,
            "password": sharedSecret
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let url = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        guard let jsonResponse else {
            throw NSError(domain: "ReceiptVerification", code: -1, userInfo: nil)
        }
        return jsonResponse
    }

    private func parseReceipt(_ receiptInfo: [String: Any], for productIdentifiers: [String]) -> [String] {
        guard let receipt = receiptInfo["receipt"] as? [String: Any],
              let inApp = receipt["in_app"] as? [[String: Any]] else { return [] }

        let now = Date()

        let activeSubscriptions = inApp.compactMap { transaction -> String? in
            guard let productId = transaction["product_id"] as? String,
                  let expirationDateString = transaction["expires_date"] as? String,
                  let expirationDate = ISO8601DateFormatter().date(from: expirationDateString) else {
                return nil
            }

            if productIdentifiers.contains(productId) && expirationDate > now {
                return productId
            }
            return nil
        }
        return activeSubscriptions
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let continuation = continuation else { return }
        continuation.resume(returning: response.products)
        self.continuation = nil
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard let continuation = continuation else { return }
        continuation.resume(throwing: error)
        self.continuation = nil
    }
}
