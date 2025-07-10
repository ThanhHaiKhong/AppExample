//
//  ContextMenu+Action.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation
import UIKit

extension ContextMenu {
	public struct Action: Identifiable, Sendable {
		public let id: ID
		public let title: String
		public let image: UIImage?
		public let kind: Kind
		public var attributes: Attributes
		public var state: State
		public let deferredProvider: (@Sendable () async -> [Action])?
		
		public init(
			id: ID,
			title: String = "",
			image: UIImage? = nil,
			kind: Kind = .default,
			attributes: Attributes = [],
			state: State = .off,
			deferredProvider: (@Sendable () async -> [Action])? = nil
		) {
			self.id = id
			self.title = title
			self.image = image
			self.kind = kind
			self.attributes = attributes
			self.state = state
			self.deferredProvider = deferredProvider
		}
	}
}

// MARK: - Equatable

extension ContextMenu.Action: Equatable {
	public static func == (lhs: ContextMenu.Action, rhs: ContextMenu.Action) -> Bool {
		lhs.id == rhs.id &&
		lhs.title == rhs.title &&
		lhs.image == rhs.image &&
		lhs.attributes == rhs.attributes &&
		lhs.state == rhs.state &&
		lhs.deferredProvider as AnyObject === rhs.deferredProvider as AnyObject
	}
}

// MARK: - Identifiable ID

extension ContextMenu.Action {
	public struct ID: RawRepresentable, Identifiable, Sendable, Hashable {
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

// MARK: - Attributes

extension ContextMenu.Action {
	public struct Attributes: OptionSet, Sendable, Equatable {
		public let rawValue: Int
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		public static let disabled = Attributes(rawValue: 1 << 0)
		public static let destructive = Attributes(rawValue: 1 << 1)
		public static let hidden = Attributes(rawValue: 1 << 2)
	}
}

// MARK: - State

extension ContextMenu.Action {
	public enum State: Sendable, Equatable {
		case off
		case on
		case mixed
	}
}

// MARK: - Configuration

extension ContextMenu.Action {
	public struct Configuration: Identifiable, Sendable, Equatable {
		public let id: ID
		public let attributesProvider: @Sendable () async -> ContextMenu.Action.Attributes
		public let stateProvider: @Sendable () async -> ContextMenu.Action.State
		
		public init(
			id: ID,
			attributesProvider: @escaping @Sendable () async -> ContextMenu.Action.Attributes,
			stateProvider: @escaping @Sendable () async -> ContextMenu.Action.State
		) {
			self.id = id
			self.attributesProvider = attributesProvider
			self.stateProvider = stateProvider
		}
		
		public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
			lhs.id == rhs.id
		}
	}
}

extension ContextMenu.Action {
	public struct Kind: RawRepresentable, Sendable, Equatable {
		public let rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		public init(_ type: String) {
			self.rawValue = type
		}
	}
}

extension ContextMenu.Action {
	@MainActor
	public func toUIMenuElement(_ handler: ((ContextMenu.Action, AnyContextMenuBuildable) -> Void)?, from source: AnyContextMenuBuildable) -> UIMenuElement {
		if let deferredProvider = deferredProvider {
			return UIMenu(
				title: title,
				image: image,
				identifier: UIMenu.Identifier(id.rawValue),
				options: [],
				children: [
					UIDeferredMenuElement { completion in
						Task {
							let actions = await deferredProvider()
							let children = actions.map { $0.toUIMenuElement(handler, from: source) }
							completion(children)
						}
					}
				]
			)
		} else {
			return UIAction(
				title: title,
				image: image,
				identifier: UIAction.Identifier(id.rawValue),
				attributes: attributes.toUIActionAttributes,
				state: state.toUIActionState,
				handler: { _ in
					handler?(self, source)
				}
			)
		}
	}
	
	@MainActor
	public mutating func applying(configure: Configuration) async {
		self.attributes = await configure.attributesProvider()
		self.state = await configure.stateProvider()
	}
}

extension ContextMenu.Action {
	
	public static let share = ContextMenu.Action(
		id: .share,
		title: "Share",
		image: UIImage(systemName: "square.and.arrow.up"),
		attributes: []
	)
	
	public static let favorite = ContextMenu.Action(
		id: .favorite,
		title: "Favorite",
		image: UIImage(systemName: "star"),
		attributes: []
	)
	
	public static let unfavorite = ContextMenu.Action(
		id: .unfavorite,
		title: "Unfavorite",
		image: UIImage(systemName: "star.slash"),
		attributes: []
	)
	
	public static let viewFullLyrics = ContextMenu.Action(
		id: .viewFullLyrics,
		title: "View Full Lyrics",
		image: UIImage(systemName: "text.bubble"),
		attributes: []
	)
	
	public static let reportAConcern = ContextMenu.Action(
		id: .reportAConcern,
		title: "Report a Concern",
		image: UIImage(systemName: "exclamationmark.bubble"),
		attributes: []
	)
	
	public static let addToLibrary = ContextMenu.Action(
		id: .addToLibrary,
		title: "Add to Library",
		image: UIImage(systemName: "plus"),
		attributes: []
	)
	
	public static let addToAPlaylist = ContextMenu.Action(
		id: .addToAPlaylist,
		title: "Add to a Playlist...",
		image: UIImage(systemName: "text.badge.plus"),
		attributes: []
	) {
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		let playlists = ["Hot Hits", "Chill Vibes", "Workout Mix", "Throwback Classics", "Favorites"]
		var actions = [ContextMenu.Action]()
		
		for playlist in playlists {
			let action = ContextMenu.Action(
				id: ContextMenu.Action.ID(playlist),
				title: playlist,
				image: UIImage(systemName: "music.note.list"),
				attributes: playlist == "Favorites" ? [.disabled] : [],
				state: .off
			)
			actions.append(action)
		}
		return actions
	}
	
	public static let playNext = ContextMenu.Action(
		id: .playNext,
		title: "Play Next",
		image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward"),
		attributes: [],
	)
	
	public static let addToQueue = ContextMenu.Action(
		id: .addToQueue,
		title: "Add to Queue",
		image: UIImage(systemName: "text.line.last.and.arrowtriangle.forward"),
		attributes: []
	)
	
	public static let remove = ContextMenu.Action(
		id: .remove,
		title: "Remove...",
		image: UIImage(systemName: "xmark.bin"),
		attributes: []
	)
	
	public static let removeFromAllPlaylists = ContextMenu.Action(
		id: .removeFromAllPlaylists,
		title: "Remove from all Playlists",
		image: UIImage(systemName: "rectangle.stack.badge.minus"),
		attributes: [.destructive]
	)
	
	public static let deleteFromLibrary = ContextMenu.Action(
		id: .deleteFromLibrary,
		title: "Delete from Library",
		image: UIImage(systemName: "trash"),
		attributes: [.destructive]
	)
}

extension ContextMenu.Action.ID {
	public static let remove = ContextMenu.Action.ID("remove")
	public static let addToLibrary = ContextMenu.Action.ID("addToLibrary")
	public static let addToAPlaylist = ContextMenu.Action.ID("addToAPlaylist")
	public static let share = ContextMenu.Action.ID("share")
	public static let reportAConcern = ContextMenu.Action.ID("reportAConcern")
	public static let favorite = ContextMenu.Action.ID("favorite")
	public static let unfavorite = ContextMenu.Action.ID("unfavorite")
	public static let viewFullLyrics = ContextMenu.Action.ID("viewFullLyrics")
	public static let playNext = ContextMenu.Action.ID("playNext")
	public static let addToQueue = ContextMenu.Action.ID("addToQueue")
	public static let deleteFromLibrary = ContextMenu.Action.ID("deleteFromLibrary")
	public static let removeFromAllPlaylists = ContextMenu.Action.ID("removeFromAllPlaylists")
}

extension ContextMenu.Action.Attributes {
	@MainActor
	public var toUIActionAttributes: UIMenuElement.Attributes {
		var attributes: UIMenuElement.Attributes = []
		
		if contains(.disabled) {
			attributes.insert(.disabled)
		}
		if contains(.destructive) {
			attributes.insert(.destructive)
		}
		if contains(.hidden) {
			attributes.insert(.hidden)
		}
		
		return attributes
	}
}

extension ContextMenu.Action.State {
	@MainActor
	public var toUIActionState: UIMenuElement.State {
		switch self {
		case .off: return .off
		case .on: return .on
		case .mixed: return .mixed
		}
	}
}

extension ContextMenu.Action.Kind {
	public static let `default` = ContextMenu.Action.Kind(rawValue: "defaultAction")
}
