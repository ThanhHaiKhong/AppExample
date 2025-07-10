//
//  ContextMenu+Configuration.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation

extension ContextMenu {
	public struct Configuration: Sendable {
		public let menuBuilder: @Sendable ([ContextMenu.Action.Configuration], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextMenu
		
		public init(
			menuBuilder: @escaping @Sendable ([ContextMenu.Action.Configuration], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextMenu
		) {
			self.menuBuilder = menuBuilder
		}
	}
}
