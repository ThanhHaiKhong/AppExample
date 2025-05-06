//
//  Models.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 27/3/25.
//

import Foundation
import CasePaths
import StoreKit

// MARK: - StoreKitClient.Product

extension StoreKitClient {
    public struct Product: Equatable, Sendable, Hashable {
        public var id: String
        public var displayName: String
        public var description: String
        public var price: Decimal
        public var displayPrice: String
        public var type: StoreKit.Product.ProductType
        
        public init(
            id: String,
            displayName: String,
            description: String,
            price: Decimal,
            displayPrice: String,
            type: StoreKit.Product.ProductType
        ) {
            self.id = id
            self.displayName = displayName
            self.description = description
            self.price = price
            self.displayPrice = displayPrice
            self.type = type
        }
    }
}

// MARK: - StoreKitClient.Transaction

extension StoreKitClient {
    public struct Transaction: Equatable, Sendable {
        public let rawValue: StoreKit.Transaction?
        
        public var id: UInt64 { rawValue?.id ?? 0 }
        public var productID: String { rawValue?.productID ?? "" }
        public var productType: StoreKit.Product.ProductType { rawValue?.productType ?? .nonConsumable }
        public var purchaseDate: Date? { rawValue?.purchaseDate }
        public var expirationDate: Date? { rawValue?.expirationDate }
        public var purchasedQuantity: Int { rawValue?.purchasedQuantity ?? 1 }
        public var displayPrice: String? {
            
            if #available(iOS 16.0, *) {
                guard let price = rawValue?.price, let currency = rawValue?.currency else {
                    return "Unknown Price"
                }
                return "\(price) \(currency)"
            } else {
                guard let price = rawValue?.price, let currencyCode = rawValue?.currencyCode else {
                    return "Unknown Price"
                }
                return "\(price) \(currencyCode)"
            }
        }
        
        public init(rawValue: StoreKit.Transaction? = nil) {
            self.rawValue = rawValue
        }
        
        public init(
            productID: String,
            productType: StoreKit.Product.ProductType,
            purchaseDate: Date? = nil,
            expirationDate: Date? = nil,
            purchasedQuantity: Int = 1,
            displayPrice: String? = nil,
            rawValue: StoreKit.Transaction? = nil
        ) {
            self.rawValue = rawValue
        }
        
        public var isExpired: Bool {
            guard let expirationDate else { return false }
            return expirationDate < Date()
        }
        
        public static let mockConsumable = Transaction(
            productID: "com.example.coins100",
            productType: .consumable,
            purchaseDate: Date(),
            expirationDate: nil,
            purchasedQuantity: 1
        )
        
        public static let mockSubscription = Transaction(
            productID: "com.example.premium",
            productType: .autoRenewable,
            purchaseDate: Date().addingTimeInterval(-30 * 24 * 3600), // 30 days ago
            expirationDate: Date().addingTimeInterval(24 * 3600),     // 1 day from now
            purchasedQuantity: 1
        )
        
        public static let mockExpiredSubscription = Transaction(
            productID: "com.example.premium",
            productType: .autoRenewable,
            purchaseDate: Date().addingTimeInterval(-60 * 24 * 3600), // 60 days ago
            expirationDate: Date().addingTimeInterval(-24 * 3600),    // 1 day ago
            purchasedQuantity: 1
        )
    }
}

// MARK: - StoreKitClient.TransactionMonitorEvent

extension StoreKitClient {
    @CasePathable
    public enum TransactionEvent: Sendable {
        case updated(StoreKitClient.Transaction)
        case removed(StoreKitClient.Transaction)
        case verificationFailed(Error)
    }
}

// MARK: - StoreKitClient.StoreClientError

extension StoreKitClient {
    public enum StoreClientError: Error, Sendable {
        case fetchProductsFailed(productIDs: Set<String>, underlyingError: Error)
        case unverifiedTransaction(Error)
        case userCancelled
        case purchasePending
        case unknownPurchaseResult
        case productNotFound(productID: String)
    }
}
