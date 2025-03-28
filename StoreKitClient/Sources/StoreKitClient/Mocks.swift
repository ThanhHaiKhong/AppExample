//
//  Mocks.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 27/3/25.
//

import Dependencies

@available(iOS 15.0, *)
extension DependencyValues {
    public var storeKit: StoreKitClient {
        get { self[StoreKitClient.self] }
        set { self[StoreKitClient.self] = newValue }
    }
}

@available(iOS 15.0, *)
extension StoreKitClient: TestDependencyKey {
    public static let previewValue = Self.noop
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
}
