//
//  SwiftUIView.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 24/1/25.
//

import ComposableArchitecture
import GoogleMobileAds
import SwiftUI

@DependencyClient
public struct MobileAdsClient: Sendable {
    
}

extension MobileAdsClient: DependencyKey {
    public static let liveValue: MobileAdsClient = {
        return MobileAdsClient(
            
        )
    }()
}

extension MobileAdsClient: TestDependencyKey {
    public static var testValue: MobileAdsClient {
        MobileAdsClient()
    }
}

extension DependencyValues {
    public var mobileAdsClient: MobileAdsClient {
        get { self[MobileAdsClient.self] }
        set { self[MobileAdsClient.self] = newValue }
    }
}

public actor MobileAdsActor {
    private final class MobileAdsManager: NSObject, @unchecked Sendable, GADFullScreenContentDelegate {
        static let shared = MobileAdsManager()
        
        private var loadTime: Date?
        private var appOpen: GADAppOpenAd?
        private var interestitial: GADInterstitialAd?
        private var reward: GADRewardedAd?
        
        private func loadAdsIfNeed() {
            loadAppOpenAd()
            loadInterstitialAd()
        }
        
        private func loadAppOpenAd() {
            appOpen = nil
            guard let unitID = AdmobUnitIDKeys.appOpen.adUnitID else {
                return
            }
            
            GADAppOpenAd.load(withAdUnitID: unitID, request: GADRequest()) { appOpen, error in
                guard let appOpen = appOpen, error == nil else {
                    return
                }
                
                self.appOpen = appOpen
                self.appOpen?.fullScreenContentDelegate = self
                self.loadTime = Date()
            }
        }
        
        private func wasLoadTimeLessThanNHoursAgo(_ n: Int = 4) -> Bool {
            guard let loadTime = self.loadTime else { return false }
            let now = Date()
            let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(loadTime)
            let secondsPerHour: Double = 3600.0
            let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
            
            return intervalInHours < Double(n)
        }
        
        private func loadInterstitialAd() {
            guard let unitID = AdmobUnitIDKeys.interestitial.adUnitID else {
                return
            }
            
            let request = GADRequest()
            
            GADInterstitialAd.load(withAdUnitID: unitID, request: request, completionHandler: { [weak self] ad, error in
                guard let `self` = self else {
                    return
                }
                
                if error != nil {
                    return
                }
                
                self.interestitial = ad
                self.interestitial?.fullScreenContentDelegate = self
            })
        }
        
        // MARK: - GADFullScreenContentDelegate

        func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
            loadAdsIfNeed()
        }
        
        func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
            if ad is GADAppOpenAd {
                UserDefaults.standard.set(Date(), forKey: AdmobPrefKeys.openDate.rawValue)
            }
        }
        
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            if let interstitialAd = ad as? GADInterstitialAd {
                
            } else if let rewardedAd = ad as? GADRewardedAd {
                
            } else if let appOpenAd = ad as? GADAppOpenAd {
                
            }
        }
    }
}

extension GADInterstitialAd {
    
    func safeCanPresent(fromRootViewController controller: UIViewController) -> Bool {
        do {
            try self.canPresent(fromRootViewController: controller)
            return true
        } catch {
            return false
        }
    }
}

public typealias AdsWeight = Int

public enum AdsType {
    case banner, interestitial, reward, appOpen, native
    
    public var weight: AdsWeight {
        100
    }
}

enum AdmobPrefKeys: String {
    case remainningInterestitialWeight = "PREF_REMAINNING_WEIGHT_INTERSTITIAL_ADS"
    case openDate = "ADS_OPEN_DATE"
}

public enum AdmobUnitIDKeys: String {
    case banner = "GADBannerAdUnitID"
    case interestitial = "GADInterestitialAdUnitID"
    case appOpen = "GADAppOpenAdUnitID"
    case reward = "GADRewardAdUnitID"
    case native = "GADNativeAdUnitID"
 
    public var adUnitID: String? {
        Bundle.main.object(forInfoDictionaryKey: self.rawValue) as? String
    }
}

extension GADRewardedAd {
    
    func safeCanPresent(fromRootViewController controller: UIViewController) -> Bool {
        do {
            try self.canPresent(fromRootViewController: controller)
            return true
        } catch {
            return false
        }
    }
}

extension GADAppOpenAd {

    public func safeCanPresent(fromRootViewController controller: UIViewController) -> Bool {
        do {
            try self.canPresent(fromRootViewController: controller)
            return true
        } catch {
            return false
        }
    }
}
