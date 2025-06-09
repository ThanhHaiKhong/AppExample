//
//  Models.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 9/6/25.
//

import Foundation
import GoogleMobileAds

// MARK: - AdChoicesOptions

extension NativeAdClient {
	
	public protocol NativeLoaderOptions: Sendable, Equatable {
		func toAdLoaderOptions() -> GADAdLoaderOptions
	}
}

extension NativeAdClient {
	
	public struct AnyNativeLoaderOptions: Sendable, Equatable {
		private let base: any NativeLoaderOptions
		private let equals: @Sendable (any NativeLoaderOptions) -> Bool
		
		public init<T: NativeLoaderOptions & Equatable>(_ base: T) {
			self.base = base
			self.equals = { ($0 as? T) == base }
		}
		
		public var unwrapped: any NativeLoaderOptions {
			return base
		}
		
		public static func == (lhs: AnyNativeLoaderOptions, rhs: AnyNativeLoaderOptions) -> Bool {
			return lhs.equals(rhs.base)
		}
	}
}

extension NativeAdClient {
	
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
}

extension NativeAdClient {
	
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
}

extension NativeAdClient {
	
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
}

extension NativeAd: @retroactive @unchecked Sendable {
	
}

/*
 public struct AnyNativeLoaderOptions: Sendable, Equatable {
 private let base: any NativeLoaderOptions
 private let equals: @Sendable (any NativeLoaderOptions) -> Bool
 
 public init<T: NativeLoaderOptions & Equatable>(_ base: T) {
 self.base = base
 self.equals = { ($0 as? T) == base }
 }
 
 public var unwrapped: any NativeLoaderOptions {
 return base
 }
 
 public static func == (lhs: AnyNativeLoaderOptions, rhs: AnyNativeLoaderOptions) -> Bool {
 return lhs.equals(rhs.base)
 }
 }
 */
