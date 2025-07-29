//
//  ContextualMenu.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 6/7/25.
//

import UIKit

public struct ContextualMenu: Identifiable, Sendable {
	public let id: String
	public let source: AnyContextMenuBuildable
	public let title: String
	public let image: UIImage?
	public let options: Options
	public var sections: [Section]
	public var handler: ((@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void))?
	
	public init(
		id: String = UUID().uuidString,
		source: AnyContextMenuBuildable,
		title: String = "",
		image: UIImage? = nil,
		options: Options = [],
		@MenuSectionBuilder _ builder: () -> [Section],
		handler: (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)? = nil
	) {
		self.id = id
		self.source = source
		self.title = title
		self.image = image
		self.options = options
		self.sections = builder()
		self.handler = handler
	}
	
	public init(
		id: String = UUID().uuidString,
		source: AnyContextMenuBuildable,
		title: String = "",
		image: UIImage? = nil,
		options: Options = [],
		sections: [Section],
		handler: (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)? = nil
	) {
		self.id = id
		self.source = source
		self.title = title
		self.image = image
		self.options = options
		self.sections = sections
		self.handler = handler
	}
}

// MARK: - Equatable

extension ContextualMenu: Equatable {
	public static func == (lhs: ContextualMenu, rhs: ContextualMenu) -> Bool {
		lhs.id == rhs.id &&
		lhs.title == rhs.title &&
		lhs.image == rhs.image &&
		lhs.options == rhs.options &&
		lhs.sections == rhs.sections
	}
}

// MARK: - Supporting Methods

extension ContextualMenu {
	@MainActor
	public func toUIMenu() -> UIMenu {
		if sections.count == 1 {
			let children = sections[0].toUIMenuElement(handler, from: source)
			
			if children is UIAction {
				return UIMenu(
					title: title,
					image: image,
					identifier: UIMenu.Identifier(id),
					options: options.toUIMenuOptions,
					children: [children]
				)
			} else if children is UIMenu {
				return children as! UIMenu
			} else {
				return UIMenu(
					title: title,
					image: image,
					identifier: UIMenu.Identifier(id),
					options: options.toUIMenuOptions,
					children: [children]
				)
			}
		} else {
			var mainChildren: [UIMenuElement] = []
			
			for section in sections {
				let children = section.toUIMenuElement(handler, from: source)
				let menu = UIMenu(
					title: section.header,
					image: section.image,
					identifier: UIMenu.Identifier(section.id.rawValue),
					options: [.displayInline],
					children: [children]
				)
				mainChildren.append(menu)
			}
			
			return UIMenu(
				title: title,
				image: image,
				identifier: UIMenu.Identifier(id),
				options: options.toUIMenuOptions,
				children: mainChildren
			)
		}
	}
}

extension ContextualMenu {
	
	public mutating func updateDefferedProvider(
		_ provider: @escaping ContextualMenu.DeferredProvider,
		for actionID: ContextualMenu.Action.ID
	) {
		for sectionIndex in sections.indices {
			for itemIndex in sections[sectionIndex].children.indices {
				switch sections[sectionIndex].children[itemIndex] {
				case .action(var action) where action.id == actionID:
					action.deferredProvider = provider
					sections[sectionIndex].children[itemIndex] = .action(action)
					return
					
				default:
					continue
				}
			}
		}
	}
}
