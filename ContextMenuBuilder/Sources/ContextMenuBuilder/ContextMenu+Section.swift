//
//  ContextMenu+Section.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation
import UIKit

extension ContextMenu {
	public struct Section: Sendable {
		public let id: ID
		public let header: String
		public let title: String
		public let image: UIImage?
		public let options: ContextMenu.Options
		public let children: [Item]
		
		public init(
			id: ID,
			header: String = "",
			title: String = "",
			image: UIImage? = nil,
			options: ContextMenu.Options = [],
			@MenuItemBuilder _ builder: () -> [ContextMenu.Section.Item]
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
			options: ContextMenu.Options = [],
			children: [ContextMenu.Section.Item] = []
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

extension ContextMenu.Section: Equatable {
	public static func == (lhs: ContextMenu.Section, rhs: ContextMenu.Section) -> Bool {
		lhs.id == rhs.id &&
		lhs.header == rhs.header &&
		lhs.title == rhs.title &&
		lhs.image == rhs.image &&
		lhs.options == rhs.options &&
		lhs.children == rhs.children
	}
}

// MARK: - Identifiable

extension ContextMenu.Section {
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

extension ContextMenu.Section {
	public enum Item: Sendable, Equatable {
		case action(ContextMenu.Action, ContextMenu.Action.Configuration)
		case submenu(ContextMenu)
	}
}

// MARK: - Builder

@resultBuilder
public struct MenuItemBuilder {
	public static func buildBlock(_ components: ContextMenu.Section.Item...) -> [ContextMenu.Section.Item] {
		components
	}
	
	public static func buildOptional(_ component: [ContextMenu.Section.Item]?) -> [ContextMenu.Section.Item] {
		component ?? []
	}
	
	public static func buildEither(first component: [ContextMenu.Section.Item]) -> [ContextMenu.Section.Item] {
		component
	}
	
	public static func buildEither(second component: [ContextMenu.Section.Item]) -> [ContextMenu.Section.Item] {
		component
	}
	
	public static func buildArray(_ components: [[ContextMenu.Section.Item]]) -> [ContextMenu.Section.Item] {
		components.flatMap { $0 }
	}
}


extension ContextMenu.Section {
	@MainActor
	func toUIMenuElement(_ handler: ((ContextMenu.Action, AnyContextMenuBuildable) -> Void)?, from source: AnyContextMenuBuildable) -> UIMenuElement {
		let elements = children.map {
			switch $0 {
			case let .action(action, _): return action.toUIMenuElement(handler, from: source) as UIMenuElement
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

extension ContextMenu.Section {
	
	public static let library = ContextMenu.Section(
		id: .library,
		options: [.displayInline]
	) {
		Item.action(.addToAPlaylist, .default)
		Item.action(.addToLibrary, .default)
	}
	
	public static let favorite = ContextMenu.Section(
		id: .favorite,
		options: [.displayInline]
	) {
		Item.action(.viewFullLyrics, .default)
		Item.action(.favorite, .default)
	}
	
	public static let share = ContextMenu.Section(
		id: .share,
		options: [.displayInline]
	) {
		Item.action(.reportAConcern, .default)
		Item.action(.share, .default)
	}
	
	public static let queue = ContextMenu.Section(
		id: .queue,
		options: [.displayInline]
	) {
		Item.action(.addToQueue, .default)
		Item.action(.playNext, .default)
	}
	
	public static let remove = ContextMenu.Section(
		id: .remove,
		title: "Remove...",
		image: UIImage(systemName: "xmark.bin"),
		options: []
	) {
		Item.action(.removeFromAllPlaylists, .default)
		Item.action(.deleteFromLibrary, .default)
	}
}

extension ContextMenu.Section.ID {
	public static let standalone = ContextMenu.Section.ID("standaloneSection")
	public static let library = ContextMenu.Section.ID("librarySection")
	public static let share = ContextMenu.Section.ID("shareSection")
	public static let queue = ContextMenu.Section.ID("queueSection")
	public static let remove = ContextMenu.Section.ID("removeSection")
	public static let favorite = ContextMenu.Section.ID("removeSection")
}


// MARK: - Builder

@resultBuilder
public struct MenuSectionBuilder {
	public static func buildBlock(_ components: ContextMenu.Section...) -> [ContextMenu.Section] {
		components
	}
	
	public static func buildOptional(_ component: [ContextMenu.Section]?) -> [ContextMenu.Section] {
		component ?? []
	}
	
	public static func buildEither(first component: [ContextMenu.Section]) -> [ContextMenu.Section] {
		component
	}
	
	public static func buildEither(second component: [ContextMenu.Section]) -> [ContextMenu.Section] {
		component
	}
	
	public static func buildArray(_ components: [[ContextMenu.Section]]) -> [ContextMenu.Section] {
		components.flatMap { $0 }
	}
}
