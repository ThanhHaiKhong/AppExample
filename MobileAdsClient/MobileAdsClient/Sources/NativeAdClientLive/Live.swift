//
//  Live.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import ComposableArchitecture
import NativeAdClient

extension NativeAdClient: DependencyKey {
    public static let liveValue: NativeAdClient = {
        return NativeAdClient(
            loadAd: { adUnitID, viewController, options in
                return try await AdsManager.shared.loadAd(adUnitID: adUnitID, from: viewController, options: options)
            }
        )
    }()
}
