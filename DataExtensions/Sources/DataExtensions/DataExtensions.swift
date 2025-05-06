// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

extension Array {
	public func subarray(from index: Int) -> [Element] {
		guard index >= 0 && index < self.count else {
			return []
		}
		return Array(self[index...])
	}
}

extension TimeInterval {
	public var formatted: String {
		let totalSeconds = Int(self)
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
	
	public var timeString: String {
		let totalSeconds = Int(self)
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60
		
		// display --:-- if totalSeconds <= 0
		
		if totalSeconds <= 0 {
			return "--:--"
		}
		
		if hours > 0 {
			return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
		} else {
			return String(format: "%02d:%02d", minutes, seconds)
		}
	}
}
