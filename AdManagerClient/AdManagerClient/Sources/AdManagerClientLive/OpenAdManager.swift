//
//  OpenAdManager.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import GoogleMobileAds
import AdManagerClient

final internal class OpenAdManager: NSObject, @unchecked Sendable {
    private var appOpenAds: [String: AppOpenAd] = [:]
    private var dismissContinuations: [String: CheckedContinuation<Void, Error>] = [:]
    
    override init() {
        super.init()
    }
}

// MARK: - Public Methods

extension OpenAdManager {
    public func shouldShowAd(_ adUnitID: String, rules: [AdManagerClient.AdRule]) async -> Bool {
        if appOpenAds[adUnitID] == nil {
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
        guard let ad = appOpenAds[adUnitID] else {
            throw AdManagerClient.AdError.adNotReady
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            dismissContinuations[adUnitID] = continuation
            ad.present(from: viewController)
        }
    }
}

// MARK: - Private Methods

extension OpenAdManager {
    private func loadAd(adUnitID: String) async throws {
        let ad = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppOpenAd, Error>) in
            let request = Request()
            AppOpenAd.load(with: adUnitID, request: request) { ad, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
        appOpenAds.removeValue(forKey: adUnitID)
        appOpenAds[adUnitID] = ad
    }
}

// MARK: - FullScreenContentDelegate

extension OpenAdManager: FullScreenContentDelegate {
    
    @objc
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        for (adUnitID, storedAd) in appOpenAds where storedAd === ad {
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
        for (adUnitID, storedAd) in appOpenAds where storedAd === ad {
            dismissContinuations[adUnitID]?.resume(throwing: error)
            dismissContinuations.removeValue(forKey: adUnitID)
            break
        }
    }
}

extension AppOpenAd: @retroactive @unchecked Sendable {
    
}
