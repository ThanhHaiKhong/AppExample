//
//  InterstitialAdManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import GoogleMobileAds
import MobileAdsClient

final internal class InterstitialAdManager: NSObject, @unchecked Sendable {
    private var interstitials: [String: InterstitialAd] = [:]
    private var dismissContinuations: [String: CheckedContinuation<Void, Error>] = [:]
    
    override init() {
        super.init()
    }
}

// MARK: - Public Methods

extension InterstitialAdManager {
    public func shouldShowAd(_ adUnitID: String, rules: [MobileAdsClient.AdRule]) async -> Bool {
		let isSatisfied = await rules.allRulesSatisfied()
		
        if interstitials[adUnitID] == nil {
            do {
                try await loadAd(adUnitID: adUnitID)
                #if DEBUG
                print("🍺 INTERSTITIAL ad loaded successfully")
                #endif
                return isSatisfied
            } catch {
                #if DEBUG
                print("🌶️ Failed to loading INTERSTITIAL ad: \(error.localizedDescription)")
                #endif
                return false
            }
        }
        
        return isSatisfied
    }
    
    @MainActor
    public func showAd(_ adUnitID: String, from viewController: UIViewController) async throws {
        guard let ad = interstitials[adUnitID] else {
            throw MobileAdsClient.AdError.adNotReady
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            dismissContinuations[adUnitID] = continuation
            ad.present(from: viewController)
        }
    }
}

// MARK: - Private Methods

extension InterstitialAdManager {
    private func loadAd(adUnitID: String) async throws {
        let ad = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<InterstitialAd, Error>) in
            let request = Request()
            InterstitialAd.load(with: adUnitID, request: request) { ad, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
        interstitials.removeValue(forKey: adUnitID)
        interstitials[adUnitID] = ad
    }
}

// MARK: - FullScreenContentDelegate

extension InterstitialAdManager: FullScreenContentDelegate {
    
    @objc
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        for (adUnitID, storedAd) in interstitials where storedAd === ad {
            dismissContinuations[adUnitID]?.resume(returning: ())
            dismissContinuations.removeValue(forKey: adUnitID)
            
            Task {
                try? await loadAd(adUnitID: adUnitID)
            }
            break
        }
    }
    
    @objc
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        for (adUnitID, storedAd) in interstitials where storedAd === ad {
            dismissContinuations[adUnitID]?.resume(throwing: error)
            dismissContinuations.removeValue(forKey: adUnitID)
            break
        }
    }
}

extension InterstitialAd: @retroactive @unchecked Sendable {
    
}
