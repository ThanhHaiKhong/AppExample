//
//  Models.swift
//  TimerClient
//
//  Created by Thanh Hai Khong on 29/4/25.
//

import Foundation

extension TimerClient {
	public struct TimerID: Hashable, Sendable, Equatable {
		public let rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
	}
	
	public enum TimerMode: Sendable, Equatable {
		case regular // Counts up from 0
		case countdown(TimeInterval) // Counts down from specified duration to 0
		
		public static func == (lhs: TimerMode, rhs: TimerMode) -> Bool {
			switch (lhs, rhs) {
			case (.regular, .regular):
				return true
			case (.countdown(let lhsDuration), .countdown(let rhsDuration)):
				return lhsDuration == rhsDuration
			default:
				return false
			}
		}
	}
	
	public enum TimerResult: Sendable, Equatable {
		case tick(TimeInterval)
		case completed
		case stoppedManually
		case cancelled
		
		public static func == (lhs: TimerResult, rhs: TimerResult) -> Bool {
			switch (lhs, rhs) {
			case (.tick(let lhsTime), .tick(let rhsTime)):
				return lhsTime == rhsTime
			case (.completed, .completed):
				return true
			case (.stoppedManually, .stoppedManually):
				return true
			case (.cancelled, .cancelled):
				return true
			default:
				return false
			}
		}
	}
}
