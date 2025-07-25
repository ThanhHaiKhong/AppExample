//
//  ContextualMenu+Action.swift
//  ContextMenuBuilder
//
//  Created by Thanh Hai Khong on 8/7/25.
//

import Foundation
import UIKit

extension ContextualMenu {
	
	public typealias DeferredProvider = @Sendable () async -> [Action]
	
	public struct Action: Identifiable, Sendable {
		public let id: ID
		public let title: String
		public let image: UIImage?
		public let kind: Kind
		public var attributes: Attributes
		public var state: State
		public let deferredProvider: DeferredProvider?
		
		public init(
			id: ID,
			title: String = "",
			image: UIImage? = nil,
			kind: Kind = .default,
			attributes: Attributes = [],
			state: State = .off,
			deferredProvider: DeferredProvider? = nil
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

extension ContextualMenu.Action: Equatable {
	public static func == (lhs: ContextualMenu.Action, rhs: ContextualMenu.Action) -> Bool {
		lhs.id == rhs.id &&
		lhs.title == rhs.title &&
		lhs.image == rhs.image &&
		lhs.attributes == rhs.attributes &&
		lhs.state == rhs.state &&
		lhs.deferredProvider as AnyObject === rhs.deferredProvider as AnyObject
	}
}

// MARK: - Identifiable ID

extension ContextualMenu.Action {
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

extension ContextualMenu.Action {
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

extension ContextualMenu.Action {
	public enum State: Sendable, Equatable {
		case off
		case on
		case mixed
	}
}

// MARK: - Configuration

extension ContextualMenu.Action {
	public struct Configuration: Identifiable, Sendable, Equatable {
		public let id: ID
		public let attributesProvider: @Sendable () async -> ContextualMenu.Action.Attributes
		public let stateProvider: @Sendable () async -> ContextualMenu.Action.State
		
		public init(
			id: ID,
			attributesProvider: @escaping @Sendable () async -> ContextualMenu.Action.Attributes,
			stateProvider: @escaping @Sendable () async -> ContextualMenu.Action.State
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

// MARK: - Kind

extension ContextualMenu.Action {
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

// MARK: - Conversion to UIMenuElement

extension ContextualMenu.Action {
	@MainActor
	public func toUIMenuElement(
		_ handler: ((ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?,
		from source: AnyContextMenuBuildable
	) -> UIMenuElement {
		if let deferredProvider = deferredProvider {
			let attributes = attributes.toUIActionAttributes

			if attributes.contains(.disabled) || attributes.contains(.hidden) {
				return UIAction(
					title: title,
					image: image,
					identifier: UIAction.Identifier(id.rawValue),
					attributes: attributes,
					state: state.toUIActionState,
					handler: { _ in
						handler?(self, source)
					}
				)
			} else if attributes.contains(.destructive) {
				return UIMenu(
					title: title,
					image: image,
					identifier: UIMenu.Identifier(id.rawValue),
					options: [.destructive],
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
			}
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

// MARK: - Predefined Actions

extension ContextualMenu.Action {
	
	public static let share = ContextualMenu.Action(
		id: .share,
		title: "Share",
		image: UIImage(systemName: "square.and.arrow.up")
	)
	
	public static let favorite = ContextualMenu.Action(
		id: .favorite,
		title: "Favorite",
		image: UIImage(systemName: "star")
	)
	
	public static let unfavorite = ContextualMenu.Action(
		id: .unfavorite,
		title: "Unfavorite",
		image: UIImage(systemName: "star.slash")
	)
	
	public static let viewFullLyrics = ContextualMenu.Action(
		id: .viewFullLyrics,
		title: "View Full Lyrics",
		image: UIImage(systemName: "text.bubble")
	)
	
	public static let reportAConcern = ContextualMenu.Action(
		id: .reportAConcern,
		title: "Report a Concern",
		image: UIImage(systemName: "exclamationmark.bubble")
	)
	
	public static let addToLibrary = ContextualMenu.Action(
		id: .addToLibrary,
		title: "Add to Library",
		image: UIImage(systemName: "plus")
	)
	
	public static let addToAPlaylist = ContextualMenu.Action(
		id: .addToAPlaylist,
		title: "Add to a Playlist...",
		image: UIImage(systemName: "text.badge.plus")
	) {
		try? await Task.sleep(nanoseconds: 1_000_000_000)
		let playlists = ["Hot Hits", "Chill Vibes", "Workout Mix", "Throwback Classics", "Favorites"]
		var actions = [ContextualMenu.Action]()
		
		for playlist in playlists {
			let action = ContextualMenu.Action(
				id: ContextualMenu.Action.ID(playlist),
				title: playlist,
				image: UIImage(systemName: "music.note.list"),
				attributes: playlist == "Favorites" ? [.destructive] : [],
				state: .off
			)
			actions.append(action)
		}
		return actions
	}
	
	public static let playNext = ContextualMenu.Action(
		id: .playNext,
		title: "Play Next",
		image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward")
	)
	
	public static let addToQueue = ContextualMenu.Action(
		id: .addToQueue,
		title: "Add to Queue",
		image: UIImage(systemName: "text.line.last.and.arrowtriangle.forward")
	)
	
	public static let remove = ContextualMenu.Action(
		id: .remove,
		title: "Remove...",
		image: UIImage(systemName: "xmark.bin")
	) {
		return [.removeFromAllPlaylists, .deleteFromLibrary]
	}
	
	public static let removeFromAllPlaylists = ContextualMenu.Action(
		id: .removeFromAllPlaylists,
		title: "Remove from all Playlists",
		image: UIImage(systemName: "rectangle.stack.badge.minus"),
		attributes: [.destructive]
	)
	
	public static let deleteFromLibrary = ContextualMenu.Action(
		id: .deleteFromLibrary,
		title: "Delete from Library",
		image: UIImage(systemName: "trash"),
		attributes: [.destructive]
	)
}

// MARK: - Predefined Action IDs

extension ContextualMenu.Action.ID {
	public static let remove = ContextualMenu.Action.ID("remove")
	public static let addToLibrary = ContextualMenu.Action.ID("addToLibrary")
	public static let addToAPlaylist = ContextualMenu.Action.ID("addToAPlaylist")
	public static let share = ContextualMenu.Action.ID("share")
	public static let reportAConcern = ContextualMenu.Action.ID("reportAConcern")
	public static let favorite = ContextualMenu.Action.ID("favorite")
	public static let unfavorite = ContextualMenu.Action.ID("unfavorite")
	public static let viewFullLyrics = ContextualMenu.Action.ID("viewFullLyrics")
	public static let playNext = ContextualMenu.Action.ID("playNext")
	public static let addToQueue = ContextualMenu.Action.ID("addToQueue")
	public static let deleteFromLibrary = ContextualMenu.Action.ID("deleteFromLibrary")
	public static let removeFromAllPlaylists = ContextualMenu.Action.ID("removeFromAllPlaylists")
}

// MARK: - Conversion to UIMenuElement Attributes

extension ContextualMenu.Action.Attributes {
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

// MARK: - Conversion to UIMenuElement State

extension ContextualMenu.Action.State {
	@MainActor
	public var toUIActionState: UIMenuElement.State {
		switch self {
		case .off: return .off
		case .on: return .on
		case .mixed: return .mixed
		}
	}
}

// MARK: - Predefined Action Kinds

extension ContextualMenu.Action.Kind {
	public static let `default` = ContextualMenu.Action.Kind(rawValue: "defaultAction")
}
