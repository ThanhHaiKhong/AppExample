//
//  NativeAdClient.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import ComposableArchitecture
import GoogleMobileAds

public struct NativeAdResponse: Sendable {
    public let headline: String?
    public let body: String?
    public let callToAction: String?
    public let icon: UIImage?
    public let images: [UIImage]?
    public let store: String?
    public let price: String?
    public let advertiser: String?
    public let starRating: Double?
    public let mediaContent: MediaContent
}

extension NativeAdResponse {
    public init(from ad: NativeAd) {
        self.headline = ad.headline
        self.body = ad.body
        self.callToAction = ad.callToAction
        self.icon = ad.icon?.image
        self.images = ad.images?.compactMap { $0.image }
        self.store = ad.store
        self.price = ad.price
        self.advertiser = ad.advertiser
        self.starRating = ad.starRating?.doubleValue
        self.mediaContent = ad.mediaContent
    }
}

@DependencyClient
public struct NativeAdClient: Sendable {
    public var loadAd: @Sendable (_ adUnitID: String, _ rootViewController: UIViewController?) async throws -> NativeAd
}

extension DependencyValues {
    public var nativeAdClient: NativeAdClient {
        get { self[NativeAdClient.self] }
        set { self[NativeAdClient.self] = newValue }
    }
}

extension NativeAd: @retroactive @unchecked Sendable {
    
}

extension MediaContent: @retroactive @unchecked Sendable {
    
}
