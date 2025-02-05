//
//  InAppPurchaseClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 23/1/25.
//

import ComposableArchitecture
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
        let manager = Delegate()
        return InAppPurchaseClient(
            fetchProducts: { productIdentifiers in
                return try await manager.fetchProducts(identifiers: productIdentifiers)
            },
            purchase: { productID in
                return try await manager.purchase(productID)
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

public enum SubscriptionStatus {
    case active
    case expired
    case notPurchased
}

@available(iOS 15.0, *)
internal final class Delegate: @unchecked Sendable {
    private var continuation: CheckedContinuation<[Product], Error>?
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observeTransactionUpdates()
    }
    
    private func observeTransactionUpdates() {
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try await checkVerified(result)
                    await handleTransaction(transaction)
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    private func handleTransaction(_ transaction: Transaction) async {
        print("✅ Xử lý giao dịch \(transaction.id) - \(transaction.productID)")
        await transaction.finish()
    }
    
    public func fetchProducts(identifiers: [String]) async throws -> [IAPProduct] {
        let products = try await Product.products(for: identifiers)
        return products.map { IAPProduct(product: $0) }
    }

    public func purchase(_ productIdentifier: String) async throws -> Transaction {
        let product = try await getProduct(for: productIdentifier)
        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            return try await checkVerified(verificationResult)

        case .pending:
            throw NSError(domain: "PurchasePending", code: -2, userInfo: nil)

        case .userCancelled:
            throw NSError(domain: "UserCancelled", code: -3, userInfo: nil)

        @unknown default:
            throw NSError(domain: "UnknownPurchaseError", code: -4, userInfo: nil)
        }
    }

    public func restorePurchases() async throws -> [Transaction] {
        var restoredTransactions: [Transaction] = []
        for await result in Transaction.all {
            let transaction = try await checkVerified(result)
            await transaction.finish()
            restoredTransactions.append(transaction)
        }
        return restoredTransactions
    }

    public func observeTransactions() -> AsyncStream<Transaction> {
        AsyncStream { continuation in
            Task {
                for await result in Transaction.updates {
                    do {
                        let transaction = try await checkVerified(result)
                        continuation.yield(transaction)
                    } catch {
                        print("Transaction verification failed: \(error)")
                    }
                }
            }
        }
    }

    private func checkVerified(_ result: VerificationResult<Transaction>) async throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified(_, let error):
            throw error
        }
    }

    public func verifySubscriptionStatus(for productIdentifiers: [String], sharedSecret: String) async -> SubscriptionStatus {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            return .notPurchased
        }

        do {
            let receiptInfo = try await verifyReceipt(with: receiptData, sharedSecret: sharedSecret)
            let activeSubscriptions = parseReceipt(receiptInfo, for: productIdentifiers)
            return activeSubscriptions.isEmpty ? .expired : .active
        } catch {
            print("Failed to verify receipt: \(error)")
            return .notPurchased
        }
    }

    private func verifyReceipt(with receiptData: Data, sharedSecret: String) async throws -> [String: Any] {
        let requestBody = [
            "receipt-data": receiptData.base64EncodedString(),
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
              let inApp = receipt["in_app"] as? [[String: Any]] else {
            return []
        }

        let now = Date()
        let activeSubscriptions = inApp.compactMap { transaction -> String? in
            guard let productId = transaction["product_id"] as? String,
                  let expirationDateString = transaction["expires_date"] as? String,
                  let expirationDate = ISO8601DateFormatter().date(from: expirationDateString) else {
                return nil
            }
            return productIdentifiers.contains(productId) && expirationDate > now ? productId : nil
        }
        return activeSubscriptions
    }
    
    private func getProduct(for productIdentifier: String) async throws -> Product {
        guard let product = try await Product.products(for: [productIdentifier]).first else {
            throw NSError(domain: "ProductNotFound", code: -1, userInfo: nil)
        }
        return product
    }
}
