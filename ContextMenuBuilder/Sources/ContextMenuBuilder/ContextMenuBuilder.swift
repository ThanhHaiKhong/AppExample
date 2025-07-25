// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

public typealias ContextualMenuHandler = @Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void

public protocol ContextMenuBuildable: Sendable {
	var sections: [ContextualMenu.Section] { get }
	func makeConfiguration() async -> ContextualMenu.Configuration
	func makeContextMenu(configurations: [ContextualMenu.Action.Configuration], handler: ((@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void))?) async -> ContextualMenu
}

public struct AnyContextMenuBuildable: ContextMenuBuildable {
	private let _configuration: @Sendable () async -> ContextualMenu.Configuration
	private let _makeMenu: @Sendable ([ContextualMenu.Action.Configuration], (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu
	
	public let base: any ContextMenuBuildable
	
	public var sections: [ContextualMenu.Section] {
		base.sections
	}
	
	public func makeConfiguration() async -> ContextualMenu.Configuration {
		await _configuration()
	}
	
	public func makeContextMenu(configurations: [ContextualMenu.Action.Configuration], handler: (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextualMenu {
		await _makeMenu(configurations, handler)
	}
	
	public init<Base: ContextMenuBuildable>(
		_ base: Base
	) {
		self.base = base
		_configuration = { await base.makeConfiguration() }
		_makeMenu = { configurations, handler in
			await base.makeContextMenu(configurations: configurations, handler: handler)
		}
	}
}
/*
public struct Song: Identifiable, Sendable, Hashable {
	public let id: String
	public let title: String
	public let artist: String
	public let artworkURL: URL?
	
	public init(
		id: String,
		title: String,
		artist: String,
		artworkURL: URL? = nil
	) {
		self.id = id
		self.title = title
		self.artist = artist
		self.artworkURL = artworkURL
	}
}

extension Song: ContextMenuBuildable {
	
	public var sections: [ContextualMenu.Section] {
		[.library, .share, .favorite, .queue, .remove]
	}
	
	public func makeConfiguration() async -> ContextualMenu.Configuration {
		.init { configurations, handler in
			let updatedSections = await updatedSections(from: sections, using: configurations)
			return ContextualMenu(
				source: AnyContextMenuBuildable(self),
				sections: updatedSections,
				handler: handler
			)
		}
	}
	
	public func makeContextMenu(
		configurations: [ContextualMenu.Action.Configuration],
		handler: (@Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void)?
	) async -> ContextualMenu {
		let config = await makeConfiguration()
		return await config.menuBuilder(configurations, handler)
	}
	
	private func updatedSections(
		from sections: [ContextualMenu.Section],
		using configurations: [ContextualMenu.Action.Configuration]
	) async -> [ContextualMenu.Section] {
		var resultSections: [ContextualMenu.Section] = []
		for section in sections {
			var updatedItems: [ContextualMenu.Section.Item] = []
			for item in section.children {
				switch item {
				case var .action(action):
					if let config = configurations.first(where: { $0.id == action.id }) {
						await action.applying(configure: config)
						updatedItems.append(.action(action))
					} else {
						updatedItems.append(.action(action))
					}
				case .submenu:
					updatedItems.append(item)
				}
			}
			
			let updatedSection = ContextualMenu.Section(id: section.id, title: section.title, options: section.options, children: updatedItems)
			resultSections.append(updatedSection)
		}
		return resultSections
	}
}

struct ContextMenuViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let menuButton = UIButton(type: .system)
			menuButton.translatesAutoresizingMaskIntoConstraints = false
			menuButton.setTitle("Show Context Menu", for: .normal)
			menuButton.showsMenuAsPrimaryAction = true
			
			let song = Song(
				id: "1",
				title: "Song Title",
				artist: "Artist Name",
				artworkURL: URL(string: "https://example.com/artwork.jpg")
			)
			
			let handler: @Sendable (ContextualMenu.Action, AnyContextMenuBuildable) -> Void = { action, item in
				print("Selected ACTION: \(action.id) - Item: \(item.base)")
			}
			
			let addToLibraryConfig = ContextualMenu.Action.Configuration(id: .addToLibrary) {
				[]
			} stateProvider: {
				.off
			}
			
			let addToAPlaylistConfig = ContextualMenu.Action.Configuration(id: .addToAPlaylist) {
				[.disabled]
			} stateProvider: {
				.off
			}
						
			Task {
				let contextMenu = await song.makeContextMenu(
					configurations: [addToLibraryConfig, addToAPlaylistConfig],
					handler: handler
				)
				menuButton.menu = contextMenu.toUIMenu()
			}
			
			let viewController = UIViewController()
			viewController.view.backgroundColor = .systemBlue.withAlphaComponent(0.25)
			viewController.view.addSubview(menuButton)
			
			NSLayoutConstraint.activate([
				menuButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
				menuButton.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
			])
			
			return viewController
		}
		.ignoresSafeArea()
	}
}
*/
