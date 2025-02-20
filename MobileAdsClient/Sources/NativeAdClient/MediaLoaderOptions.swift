//
//  MediaLoaderOptions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import GoogleMobileAds

public struct MediaLoaderOptions: NativeLoaderOptions {
    
    private let aspectRatio: AspectRatio
    
    public init(aspectRatio: AspectRatio) {
        self.aspectRatio = aspectRatio
    }
    
    public enum AspectRatio: Int, Sendable, Equatable {
        case unknown
        case any
        case landscape
        case portrait
        case square
        
        public func toMediaAspectRatio() -> MediaAspectRatio {
            switch self {
            case .unknown:
                return .unknown
            case .any:
                return .unknown
            case .landscape:
                return .landscape
            case .portrait:
                return .portrait
            case .square:
                return .square
            }
        }
    }
    
    public func toAdLoaderOptions() -> GADAdLoaderOptions {
        let mediaOptions = NativeAdMediaAdLoaderOptions()
        mediaOptions.mediaAspectRatio = aspectRatio.toMediaAspectRatio()
        return mediaOptions
    }
}
