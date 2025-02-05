//
//  AdManager.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import GoogleMobileAds
import AdManagerClient

enum AdError: Error {
    case adNotReady
}

final internal actor AdsManager {
    internal static let shared = AdsManager()
    
    private let openAdManager = OpenAdManager()
    private let interstitialAdManager = InterstitialAdManager()
    private let rewardedAdManager = RewardedAdManager()
    private var lastAdType: AdManagerClient.AdType?
    
    private init() {
        MobileAds.shared.start(completionHandler: nil)
    }
}

// MARK: - Public Methods

extension AdsManager {
    internal func shouldShowAd(_ adType: AdManagerClient.AdType, rules: [AdManagerClient.AdRule]) async -> Bool {
        lastAdType = adType
        
        switch adType {
        case let .appOpen(adUnitID):
            return await openAdManager.shouldShowAd(adUnitID, rules: rules)
            
        case let .interstitial(adUnitID):
            return await interstitialAdManager.shouldShowAd(adUnitID, rules: rules)
            
        case let .rewarded(adUnitID):
            return await rewardedAdManager.shouldShowAd(adUnitID, rules: rules)
        }
    }
    
    @MainActor
    internal func showAd() async throws {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = scene.windows.first?.rootViewController else {
            return
        }
        
        guard let adType = await lastAdType else {
            return
        }
        
        switch adType {
        case let .appOpen(adUnitID):
            try await openAdManager.showAd(adUnitID, from: rootVC)
            print("👉 Quảng cáo APP OPEN đã bị đóng, tiếp tục thực hiện hành động tiếp theo!")
            
        case let .interstitial(adUnitID):
            try await interstitialAdManager.showAd(adUnitID, from: rootVC)
            print("👉 Quảng cáo INTERSTITIAL đã bị đóng, tiếp tục thực hiện hành động tiếp theo!")
            
        case let .rewarded(adUnitID):
            try await rewardedAdManager.showAd(adUnitID, from: rootVC)
            print("👉 Quảng cáo REWARDED đã bị đóng, tiếp tục thực hiện hành động tiếp theo!")
        }
    }
}
