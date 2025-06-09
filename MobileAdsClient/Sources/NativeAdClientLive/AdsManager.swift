//
//  AdsManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

@preconcurrency import GoogleMobileAds
import NativeAdClient

final internal actor AdsManager {
    internal static let shared = AdsManager()
    
    private let nativeAdManager = NativeAdManager.shared
    
    private init() {
        MobileAds.shared.start(completionHandler: nil)
    }
}

// MARK: - Public Methods

extension AdsManager {
    
	public func loadAd(adUnitID: String, from viewController: UIViewController?, options: [NativeAdClient.AnyNativeLoaderOptions]?) async throws -> NativeAd {
        return try await nativeAdManager.loadAd(adUnitID: adUnitID, from: viewController, options: options)
    }
}
