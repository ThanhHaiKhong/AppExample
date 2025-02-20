//
//  AdChoicesOptions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import Foundation
import GoogleMobileAds

public struct AdChoicesOptions: NativeLoaderOptions {
    private let position: Position
    
    public init(position: Position) {
        self.position = position
    }
    
    public enum Position: Int, Sendable, Equatable {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    public func toAdLoaderOptions() -> GADAdLoaderOptions {
        let adChoicesPosition: AdChoicesPosition
        switch position {
        case .topLeft:
            adChoicesPosition = .topLeftCorner
        case .topRight:
            adChoicesPosition = .topRightCorner
        case .bottomRight:
            adChoicesPosition = .bottomRightCorner
        case .bottomLeft:
            adChoicesPosition = .bottomLeftCorner
        }
        
        let nativeOptions = NativeAdViewAdOptions()
        nativeOptions.preferredAdChoicesPosition = adChoicesPosition
        
        return nativeOptions
    }
}
