//
//  ContextMenu+Section.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation
import UIKit

extension ContextualMenu {
	public struct Section: Sendable {
		public let id: ID
		public let header: String
		public let title: String
		public let image: UIImage?
		public let options: ContextualMenu.Options
		public let children: [Item]
		
		public init(
			id: ID,
			header: String = "",
			title: String = "",
			image: UIImage? = nil,
			options: ContextualMenu.Options = [],
			@MenuItemBuilder _ builder: () -> [ContextualMenu.Section.Item]
		) {
			self.id = id
			self.header = header
			self.title = title
			self.image = image
			self.options = options
			self.children = builder()
		}
		
		public init(
			id: ID,
			header: String = "",
			title: String = "",
			image: UIImage? = nil,
			options: ContextualMenu.Options = [],
			children: [ContextualMenu.Section.Item] = []
		) {
			self.id = id
			self.header = header
			self.title = title
			self.image = image
			self.options = options
			self.children = children
		}
	}
}

// MARK: - Equatable

extension ContextualMenu.Section: Equatable {
	public static func == (lhs: ContextualMenu.Section, rhs: ContextualMenu.Section) -> Bool {
		lhs.id == rhs.id &&
		lhs.header == rhs.header &&
		lhs.title == rhs.title &&
		lhs.image == rhs.image &&
		lhs.options == rhs.options &&
		lhs.children == rhs.children
	}
}

// MARK: - Identifiable

extension ContextualMenu.Section {
	public struct ID: Identifiable, RawRepresentable, Sendable, Hashable {
		public let rawValue: String
		public var id: String { rawValue }
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		public init(_ id: String) {
			self.rawValue = id
		}
	}
}

extension ContextualMenu.Section {
	public enum Item: Sendable, Equatable {
		case action(ContextualMenu.Action)
		case submenu(ContextualMenu)
	}
}

// MARK: - Builder

@resultBuilder
public struct MenuItemBuilder {
	public static func buildBlock(_ components: ContextualMenu.Section.Item...) -> [ContextualMenu.Section.Item] {
		components
	}
	
	public static func buildOptional(_ component: [ContextualMenu.Section.Item]?) -> [ContextualMenu.Section.Item] {
		component ?? []
	}
	
	public static func buildEither(first component: [ContextualMenu.Section.Item]) -> [ContextualMenu.Section.Item] {
		component
	}
	
	public static func buildEither(second component: [ContextualMenu.Section.Item]) -> [ContextualMenu.Section.Item] {
		component
	}
	
	public static func buildArray(_ components: [[ContextualMenu.Section.Item]]) -> [ContextualMenu.Section.Item] {
		components.flatMap { $0 }
	}
}


extension ContextualMenu.Section {
	@MainActor
	func toUIMenuElement(_ handler: ((ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?, from source: AnyContextMenuBuildable) -> UIMenuElement {
		let elements = children.map {
			switch $0 {
			case let .action(action): return action.toUIMenuElement(handler, from: source) as UIMenuElement
			case .submenu(let submenu): return submenu.toUIMenu() as UIMenuElement
			}
		}
		
		let children: [UIMenuElement] = elements.compactMap { $0 }
		
		if children.isEmpty {
			return UIAction(
				title: title,
				image: image,
				identifier: UIAction.Identifier(id.rawValue),
				attributes: [],
				handler: { _ in

				}
			)
		} else {
			return UIMenu(
				title: title,
				image: image,
				identifier: UIMenu.Identifier(id.rawValue),
				options: options.toUIMenuOptions,
				children: children
			)
		}
	}
}

extension ContextualMenu.Section {
	
	public static let library = ContextualMenu.Section(
		id: .library,
		options: [.displayInline]
	) {
		Item.action(.addToLibrary)
		Item.action(.addToAPlaylist)
	}
	
	public static let favorite = ContextualMenu.Section(
		id: .favorite,
		options: [.displayInline]
	) {
		Item.action(.favorite)
		Item.action(.viewFullLyrics)
	}
	
	public static let share = ContextualMenu.Section(
		id: .share,
		options: [.displayInline]
	) {
		Item.action(.share)
		Item.action(.reportAConcern)
	}
	
	public static let queue = ContextualMenu.Section(
		id: .queue,
		options: [.displayInline]
	) {
		Item.action(.playNext)
		Item.action(.addToQueue)
	}
	
	public static let remove = ContextualMenu.Section(
		id: .remove,
		title: "Remove...",
		image: UIImage(systemName: "xmark.bin"),
		options: []
	) {
		Item.action(.removeFromAllPlaylists)
		Item.action(.deleteFromLibrary)
	}
}

extension ContextualMenu.Section.ID {
	public static let standalone = ContextualMenu.Section.ID("standaloneSection")
	public static let library = ContextualMenu.Section.ID("librarySection")
	public static let share = ContextualMenu.Section.ID("shareSection")
	public static let queue = ContextualMenu.Section.ID("queueSection")
	public static let remove = ContextualMenu.Section.ID("removeSection")
	public static let favorite = ContextualMenu.Section.ID("removeSection")
}


// MARK: - Builder

@resultBuilder
public struct MenuSectionBuilder {
	public static func buildBlock(_ components: ContextualMenu.Section...) -> [ContextualMenu.Section] {
		components
	}
	
	public static func buildOptional(_ component: [ContextualMenu.Section]?) -> [ContextualMenu.Section] {
		component ?? []
	}
	
	public static func buildEither(first component: [ContextualMenu.Section]) -> [ContextualMenu.Section] {
		component
	}
	
	public static func buildEither(second component: [ContextualMenu.Section]) -> [ContextualMenu.Section] {
		component
	}
	
	public static func buildArray(_ components: [[ContextualMenu.Section]]) -> [ContextualMenu.Section] {
		components.flatMap { $0 }
	}
}
