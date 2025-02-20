//
//  RewardAdManager.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import GoogleMobileAds
import MobileAdsClient

final internal class RewardedAdManager: NSObject, @unchecked Sendable {
    private var rewardeds: [String: RewardedAd] = [:]
    private var dismissContinuations: [String: CheckedContinuation<Void, Error>] = [:]
    
    override init() {
        super.init()
    }
}

// MARK: - Public Methods

extension RewardedAdManager {
    public func shouldShowAd(_ adUnitID: String, rules: [MobileAdsClient.AdRule]) async -> Bool {
        if rewardeds[adUnitID] == nil {
            do {
                try await loadAd(adUnitID: adUnitID)
                return true
            } catch {
                return false
            }
        }
        return await rules.allRulesSatisfied()
    }
    
    @MainActor
    public func showAd(_ adUnitID: String, from viewController: UIViewController) async throws {
        guard let ad = rewardeds[adUnitID] else {
            throw MobileAdsClient.AdError.adNotReady
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            dismissContinuations[adUnitID] = continuation
            ad.present(from: viewController) {
                
            }
        }
    }
}

// MARK: - Private Methods

extension RewardedAdManager {
    private func loadAd(adUnitID: String) async throws {
        let ad = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<RewardedAd, Error>) in
            let request = Request()
            RewardedAd.load(with: adUnitID, request: request) { ad, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
        rewardeds.removeValue(forKey: adUnitID)
        rewardeds[adUnitID] = ad
    }
}

// MARK: - FullScreenContentDelegate

extension RewardedAdManager: FullScreenContentDelegate {
    
    @objc
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        for (adUnitID, storedAd) in rewardeds where storedAd === ad {
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
        for (adUnitID, storedAd) in rewardeds where storedAd === ad {
            dismissContinuations[adUnitID]?.resume(throwing: error)
            dismissContinuations.removeValue(forKey: adUnitID)
            break
        }
    }
}

extension RewardedAd: @retroactive @unchecked Sendable {
    
}
