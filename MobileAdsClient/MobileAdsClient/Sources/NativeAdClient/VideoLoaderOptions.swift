//
//  VideoOptions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import Foundation
import GoogleMobileAds

public struct VideoLoaderOptions: NativeLoaderOptions {
    private let shouldStartMuted: Bool
    private let areCustomControlsRequested: Bool
    private let isClickToExpandRequested: Bool
    
    public init(
        shouldStartMuted: Bool = false,
        areCustomControlsRequested: Bool = false,
        isClickToExpandRequested: Bool = false
    ) {
        self.shouldStartMuted = shouldStartMuted
        self.areCustomControlsRequested = areCustomControlsRequested
        self.isClickToExpandRequested = isClickToExpandRequested
    }
    
    public func toAdLoaderOptions() -> GADAdLoaderOptions {
        let videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = shouldStartMuted
        videoOptions.areCustomControlsRequested = areCustomControlsRequested
        videoOptions.isClickToExpandRequested = isClickToExpandRequested
        
        return videoOptions
    }
}
