//
//  ContextMenu+Options.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation
import UIKit

extension ContextMenu {
	public struct Options: OptionSet, Sendable, Equatable {
		public let rawValue: Int
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
}

extension ContextMenu.Options {
	public static let displayInline = ContextMenu.Options(rawValue: 1 << 0)
	public static let destructive = ContextMenu.Options(rawValue: 1 << 1)
	public static let singleSelection = ContextMenu.Options(rawValue: 1 << 2)
}

extension ContextMenu.Options {
	@MainActor
	public var toUIMenuOptions: UIMenu.Options {
		var result: UIMenu.Options = []
		if contains(.displayInline) { result.insert(.displayInline) }
		if contains(.destructive) { result.insert(.destructive) }
		if contains(.singleSelection) { result.insert(.singleSelection) }
		return result
	}
}
