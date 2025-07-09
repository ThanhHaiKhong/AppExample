//
//  ContextMenu+Configuration.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation

extension ContextMenu {
	public struct Configuration: Sendable {
		public let menuBuilder: @Sendable ([ContextMenu.Section], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) -> ContextMenu
		
		public init(
			menuBuilder: @escaping @Sendable ([ContextMenu.Section], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) -> ContextMenu
		) {
			self.menuBuilder = menuBuilder
		}
	}
}
