//
//  Models.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 9/6/25.
//

import Foundation

extension MobileAdsClient {
	public struct AdRule: Sendable, Identifiable, Equatable, CustomStringConvertible {
		public let id: String = UUID().uuidString
		public let name: String
		public let priority: Int
		public let evaluate: @Sendable () async -> Bool
		
		public init(name: String, priority: Int = 0, evaluate: @escaping @Sendable () async -> Bool) {
			self.name = name
			self.priority = priority
			self.evaluate = evaluate
		}
		
		public static func == (lhs: AdRule, rhs: AdRule) -> Bool {
			lhs.id == rhs.id
		}
		
		public var description: String {
			"""
			AdRule {
				id: \(id)
				name: "\(name)"
				priority: \(priority)
			}
			"""
		}
		
		public func detailedDescription() async -> String {
			let result = await evaluate()
			return """
			AdRule {
				id: \(id)
				name: "\(name)"
				priority: \(priority)
				evaluate result: \(result ? "✅ Passed" : "❌ Failed")
			}
			"""
		}
	}
	
	public enum AdType: Sendable, Equatable, CustomStringConvertible {
		case appOpen(AdUnitID)
		case interstitial(AdUnitID)
		case rewarded(AdUnitID)
		
		public typealias AdUnitID = String
		
		public var description: String {
			switch self {
			case .appOpen: return "APP OPEN"
			case .interstitial: return "INTERSTITIAL"
			case .rewarded: return "REWARDED"
			}
		}
	}
	
	public enum AdError: Error, Sendable, Equatable, CustomStringConvertible {
		case adNotReady
		
		public var description: String {
			switch self {
			case .adNotReady: return "The ad is not ready to be shown."
			}
		}
	}
}
