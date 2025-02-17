//
//  AdsManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

@preconcurrency import GoogleMobileAds

final internal actor AdsManager {
    internal static let shared = AdsManager()
    
    private let nativeAdManager = NativeAdManager.shared
    
    private init() {
        MobileAds.shared.start(completionHandler: nil)
    }
}

// MARK: - Public Methods

extension AdsManager {
    
    public func loadAd(adUnitID: String, from viewController: UIViewController? = nil) async throws -> NativeAd {
        return try await nativeAdManager.loadAd(adUnitID: adUnitID, from: viewController)
    }
}
