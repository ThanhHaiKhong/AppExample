//
//  NativeAdClient.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import DependenciesMacros
import GoogleMobileAds

@DependencyClient
public struct NativeAdClient: Sendable {
	public var loadAd: @Sendable (_ adUnitID: String, _ rootViewController: UIViewController?, _ options: [NativeAdClient.AnyAdLoaderOption]?) async throws -> NativeAd
}
