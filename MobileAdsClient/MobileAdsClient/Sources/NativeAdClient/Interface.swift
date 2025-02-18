//
//  NativeAdClient.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import ComposableArchitecture
import GoogleMobileAds

@DependencyClient
public struct NativeAdClient: Sendable {
    public var loadAd: @Sendable (_ adUnitID: String, _ rootViewController: UIViewController?, _ options: [AnyNativeLoaderOptions]?) async throws -> NativeAd
}

extension DependencyValues {
    public var nativeAdClient: NativeAdClient {
        get { self[NativeAdClient.self] }
        set { self[NativeAdClient.self] = newValue }
    }
}

extension NativeAd: @retroactive @unchecked Sendable {
    
}
