//
//  NativeAdManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

@preconcurrency import GoogleMobileAds
import NativeAdClient
import UIKit

final internal class NativeAdManager: NSObject, @unchecked Sendable {
    
    public static let shared = NativeAdManager()
    
    private let queue = DispatchQueue(label: "com.app.NativeAdManager.\(UUID().uuidString)", attributes: .concurrent)
    private var nativeAds: [String: [NativeAd]] = [:]
    private var pendingContinuations: [String: CheckedContinuation<NativeAd, Error>] = [:]
    private var adLoader: AdLoader?

    private override init() {
        super.init()
    }
}

// MARK: - Public Methods

extension NativeAdManager {
    
    public func loadAd(adUnitID: String, from viewController: UIViewController?, options: [AnyNativeLoaderOptions]?) async throws -> NativeAd {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NativeAd, Error>) in
            queue.async(flags: .barrier) {
                self.pendingContinuations[adUnitID] = continuation
            }
            
            var loaderOptions: [GADAdLoaderOptions] = []
            
            if let options = options {
                for option in options {
                    let loaderOption = option.unwrapped.toAdLoaderOptions()
                    loaderOptions.append(loaderOption)
                }
            }

            adLoader = AdLoader(
                adUnitID: adUnitID,
                rootViewController: viewController,
                adTypes: [.native],
                options: loaderOptions
            )
            adLoader?.delegate = self
            adLoader?.load(Request())
        }
    }
}

// MARK: - Private Methods

extension NativeAdManager {
    private func getAd(for adUnitID: String) -> NativeAd? {
        var ad: NativeAd?
        queue.sync {
            if let ads = nativeAds[adUnitID], !ads.isEmpty {
                ad = ads.first
            }
        }
        return ad
    }

    private func removeAd(for adUnitID: String) {
        queue.async(flags: .barrier) {
            self.nativeAds.removeValue(forKey: adUnitID)
        }
    }
}

// MARK: - NativeAdLoaderDelegate

extension NativeAdManager: NativeAdLoaderDelegate {
    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        let adUnitID = adLoader.adUnitID
        nativeAd.delegate = self
#if DEBUG
        print("✅ Native Ad: \(nativeAd.description) loaded for \(adUnitID)")
#endif
        queue.async(flags: .barrier) {
            if self.nativeAds[adUnitID] != nil {
                self.nativeAds[adUnitID]?.append(nativeAd)
            } else {
                self.nativeAds[adUnitID] = [nativeAd]
            }
            
            if let continuation = self.pendingContinuations.removeValue(forKey: adUnitID) {
                continuation.resume(returning: nativeAd)
            }
            
            self.adLoader = nil
        }
    }

    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        let adUnitID = adLoader.adUnitID
#if DEBUG
        print("❌ Failed to load Native Ad for \(adUnitID): \(error.localizedDescription)")
#endif
        queue.async(flags: .barrier) {
            if let continuation = self.pendingContinuations.removeValue(forKey: adUnitID) {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - NativeAdDelegate

extension NativeAdManager: NativeAdDelegate {
    
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        
    }

    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        
    }

    public func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        
    }

    public func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        
    }

    public func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        
    }
}
