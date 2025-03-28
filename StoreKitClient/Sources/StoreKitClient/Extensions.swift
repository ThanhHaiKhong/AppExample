//
//  Extensions.swift
//  StoreKitClient
//
//  Created by Thanh Hai Khong on 27/3/25.
//

import StoreKit

// MARK: - StoreKitClient.Product

extension StoreKitClient.Product {
    public init(rawValue: StoreKit.Product) {
        self.id = rawValue.id
        self.displayName = rawValue.displayName
        self.description = rawValue.description
        self.price = rawValue.price
        self.displayPrice = rawValue.displayPrice
        self.type = rawValue.type
    }
}
