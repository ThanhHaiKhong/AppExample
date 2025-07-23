//
//  ContextMenu+Configuration.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation

extension ContextualMenu {
	public struct Configuration: Sendable {
		public let menuBuilder: @Sendable ([ContextualMenu.Action.Configuration], (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu
		
		public init(
			menuBuilder: @escaping @Sendable ([ContextualMenu.Action.Configuration], (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu
		) {
			self.menuBuilder = menuBuilder
		}
	}
}
