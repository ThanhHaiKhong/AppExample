//
//  ContextMenu+Builder.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation

extension ContextualMenu {
	public struct Builder: Sendable {
		public let menuProvider: @Sendable ([ContextualMenu.Action.Configuration], (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu
		
		public init(
			menuProvider: @escaping @Sendable ([ContextualMenu.Action.Configuration], (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu
		) {
			self.menuProvider = menuProvider
		}
	}
}
