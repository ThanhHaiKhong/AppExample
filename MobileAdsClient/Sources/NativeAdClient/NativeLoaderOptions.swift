//
//  NativeLoaderOptions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import GoogleMobileAds
import Foundation

public protocol NativeLoaderOptions: Sendable, Equatable {
    func toAdLoaderOptions() -> GADAdLoaderOptions
}

public struct AnyNativeLoaderOptions: Sendable, Equatable {
    private let base: any NativeLoaderOptions
    private let equals: @Sendable (any NativeLoaderOptions) -> Bool

    public init<T: NativeLoaderOptions & Equatable>(_ base: T) {
        self.base = base
        self.equals = { ($0 as? T) == base }
    }
    
    public var unwrapped: any NativeLoaderOptions {
        return base
    }

    public static func == (lhs: AnyNativeLoaderOptions, rhs: AnyNativeLoaderOptions) -> Bool {
        return lhs.equals(rhs.base)
    }
}
