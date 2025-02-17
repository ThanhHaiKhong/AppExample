//
//  Models.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 7/2/25.
//

import GoogleMobileAds
import Foundation
import SwiftUI

// MARK: - AdvertisableType

public enum AdvertisableType: Sendable, Equatable {
    case banner(BannerType)
    case native
}

// MARK: - BannerType

public enum BannerType: Sendable, Equatable {
    case `static`(StaticCompatible)
    case anchoredAdaptive(AnchoredCompatible, collapsible: CollapsibleConfig?)
    case inlineAdaptive(InlineCompatible)
    
    public static func == (lhs: BannerType, rhs: BannerType) -> Bool {
        switch (lhs, rhs) {
        case let (.static(lhsBanner), .static(rhsBanner)):
            return lhsBanner.adSize == rhsBanner.adSize
        case let (.anchoredAdaptive(lhsBanner, lhsCollapsible), .anchoredAdaptive(rhsBanner, rhsCollapsible)):
            return lhsBanner.adSize == rhsBanner.adSize && lhsCollapsible == rhsCollapsible
        case let (.inlineAdaptive(lhsBanner), .inlineAdaptive(rhsBanner)):
            return lhsBanner.adSize == rhsBanner.adSize
        default:
            return false
        }
    }
}

// MARK: - AdSize

public protocol BannerSizable: Sendable {
    var adSize: AdSize { get }
}

public protocol StaticCompatible: BannerSizable {
    
}

public protocol InlineCompatible: BannerSizable {
    
}

public protocol AnchoredCompatible: BannerSizable {
    
}

public enum InlineAdaptiveSize: InlineCompatible, Sendable, Equatable {
    case portraitInlineAdaptiveBannerWidth(CGFloat)
    case landscapeInlineAdaptiveBannerWidth(CGFloat)
    case currentOrientationInlineAdaptiveBannerWidth(CGFloat)
    case inlineAdaptiveBannerWidth(CGFloat, CGFloat)
    
    public var adSize: AdSize {
        switch self {
        case .portraitInlineAdaptiveBannerWidth(let width):
            return portraitInlineAdaptiveBanner(width: width)
            
        case .landscapeInlineAdaptiveBannerWidth(let width):
            return landscapeInlineAdaptiveBanner(width: width)
            
        case .currentOrientationInlineAdaptiveBannerWidth(let width):
            return currentOrientationInlineAdaptiveBanner(width: width)
            
        case .inlineAdaptiveBannerWidth(let width, let maxHeight):
            return inlineAdaptiveBanner(width: width, maxHeight: maxHeight)
        }
    }
}

public enum CustomSize: StaticCompatible, Sendable, Equatable {
    case fullWidthPortraitHeight(CGFloat)
    case fullWidthLandscapeHeight(CGFloat)
    case customSize(CGSize)
    
    public var adSize: AdSize {
        switch self {
        case .fullWidthPortraitHeight(let height):
            return fullWidthPortrait(height: height)
            
        case .fullWidthLandscapeHeight(let height):
            return fullWidthLandscape(height: height)
            
        case let .customSize(customSize):
            return adSizeFor(cgSize: customSize)
        }
    }
}

public enum StandardSize: StaticCompatible, Sendable, Equatable {
    // iPhone and iPod Touch ad size. Typically 320x50.
    case banner
    
    // Taller version of GADAdSizeBanner. Typically 320x100.
    case largeBanner
    
    // Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.
    case mediumRectangle
    
    // Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet). Typically 468x60.
    case fullBanner
    
    // Leaderboard size for the iPad. Typically 728x90.
    case leaderboard
    
    // Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically 120x600.
    case skyscraper
    
    // An ad size that spans the full width of its container, with a height dynamically determined by the ad.
    case fluid
    
    // Invalid ad size marker.
    case invalid
    
    public var adSize: AdSize {
        switch self {
        case .banner:
            return AdSizeBanner
        case .largeBanner:
            return AdSizeLargeBanner
        case .mediumRectangle:
            return AdSizeMediumRectangle
        case .fullBanner:
            return AdSizeFullBanner
        case .leaderboard:
            return AdSizeLeaderboard
        case .skyscraper:
            return AdSizeSkyscraper
        case .fluid:
            return AdSizeFluid
        case .invalid:
            return AdSizeInvalid
        }
    }
}

public enum AnchoredAdaptiveSize: AnchoredCompatible, Sendable, Equatable {
    case portraitAnchoredAdaptiveBannerWidth(CGFloat)
    case landscapeAnchoredAdaptiveBannerWidth(CGFloat)
    case currentOrientationAnchoredAdaptiveBannerWidth(CGFloat)
    
    public var adSize: AdSize {
        switch self {
        case .portraitAnchoredAdaptiveBannerWidth(let width):
            return portraitAnchoredAdaptiveBanner(width: width)
            
        case .landscapeAnchoredAdaptiveBannerWidth(let width):
            return landscapeAnchoredAdaptiveBanner(width: width)
            
        case .currentOrientationAnchoredAdaptiveBannerWidth(let width):
            return currentOrientationAnchoredAdaptiveBanner(width: width)
        }
    }
}

extension AdSize: @retroactive Equatable {
    public static func == (lhs: AdSize, rhs: AdSize) -> Bool {
        return lhs.size == rhs.size
    }
}

public struct CollapsibleConfig: Equatable, Sendable {
    public let isCollapsible: Bool
    public let anchorPosition: AnchorPosition
    
    public init(isCollapsible: Bool, anchorPosition: AnchorPosition) {
        self.isCollapsible = isCollapsible
        self.anchorPosition = anchorPosition
    }
}

public enum AnchorPosition: String, Sendable, Equatable {
    case top
    case bottom
}

// MARK: - BannerLayer

public struct BannerLayer: Sendable, Equatable {
    public let cornerRadius: CGFloat
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let borderWidth: CGFloat
    
    public init(cornerRadius: CGFloat, backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    public init(cornerRadius: CGFloat, backgroundColor: UIColor) {
        self.init(cornerRadius: cornerRadius, backgroundColor: backgroundColor, borderColor: .clear, borderWidth: 0)
    }
    
    public init(cornerRadius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.init(cornerRadius: cornerRadius, backgroundColor: .clear, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    public init(backgroundColor: UIColor) {
        self.init(cornerRadius: 0, backgroundColor: backgroundColor, borderColor: .clear, borderWidth: 0)
    }
    
    public static let none: BannerLayer = .init(cornerRadius: 0, backgroundColor: .systemBackground)
    public static let clear: BannerLayer = .init(cornerRadius: 0, backgroundColor: .clear)
    public static let `default`: BannerLayer = .init(cornerRadius: 5, backgroundColor: .systemBackground)
    public static let thin: BannerLayer = .init(cornerRadius: 5, backgroundColor: .systemBackground, borderColor: .systemYellow, borderWidth: 0.5)
    public static let thick: BannerLayer = .init(cornerRadius: 5, backgroundColor: .systemBackground, borderColor: .systemYellow, borderWidth: 2.5)
}

// MARK: - BannerPadding

public struct BannerPadding: Sendable, Equatable {
    public let edgeInsets: EdgeInsets
    
    public static let none: BannerPadding = .init(edgeInsets: EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
}
