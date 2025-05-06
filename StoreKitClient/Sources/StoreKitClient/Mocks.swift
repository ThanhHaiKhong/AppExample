//
//  Mocks.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 27/3/25.
//

import Dependencies
import Foundation

@available(iOS 15.0, *)
extension DependencyValues {
    public var storeKitClient: StoreKitClient {
        get { self[StoreKitClient.self] }
        set { self[StoreKitClient.self] = newValue }
    }
}

@available(iOS 15.0, *)
extension StoreKitClient: TestDependencyKey {
    public static let previewValue = Self.happy
    public static let testValue = Self()
}

@available(iOS 15.0, *)
extension StoreKitClient {
    public static let noop = Self(
        receiptURL: { nil },
        canMakePayments: { false },
        loadProducts: { _ in try await Task.never() },
        processUnfinishedConsumables: { _ in },
        observeTransactions: { .never },
        requestReview: { },
        purchase: { _ in
            .init(productID: "com.example.product", productType: .nonConsumable, rawValue: nil)
        },
        restorePurchases: { [] }
    )
    
    public static let failing = Self(
        receiptURL: { nil },
        canMakePayments: { false },
        loadProducts: { _ in throw URLError(.badServerResponse) },
        processUnfinishedConsumables: { _ in },
        observeTransactions: { .never },
        requestReview: { },
        purchase: { _ in
            throw URLError(.badServerResponse)
        },
        restorePurchases: { [] }
    )
    
    public static let happy = Self(
        receiptURL: { nil },
        canMakePayments: { true },
        loadProducts: { _ in
            let products: [StoreKitClient.Product] = [
                .init(id: "com.example.product.weekly", displayName: "Weekly", description: "Best Offer", price: 0.99, displayPrice: "$0.99", type: .nonConsumable),
                .init(id: "com.example.product.monthly", displayName: "Monthly", description: "Best Value", price: 1.99, displayPrice: "$1.99", type: .nonConsumable),
                .init(id: "com.example.product.yearly", displayName: "Yearly", description: "Best Deal", price: 9.99, displayPrice: "$9.99", type: .nonConsumable)
            ]
            return products
        },
        processUnfinishedConsumables: { _ in },
        observeTransactions: { .never },
        requestReview: { },
        purchase: { productID in
            try await Task.sleep(nanoseconds: 5_000_000)
            let transaction = StoreKitClient.Transaction(
                productID: productID,
                productType: .nonConsumable,
                purchaseDate: Date(),
                expirationDate: Date().addingTimeInterval(7 * 24 * 3600),
                displayPrice: "$0.99",
                rawValue: nil)
            return transaction
        },
        restorePurchases: { [] }
    )
}
