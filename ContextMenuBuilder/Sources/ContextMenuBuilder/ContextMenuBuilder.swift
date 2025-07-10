// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKitPreviews
import UIKit
import SwiftUI

public protocol ContextMenuBuildable: Sendable {
	var sections: [ContextMenu.Section] { get }
	func makeConfiguration() async -> ContextMenu.Configuration
	func makeContextMenu(configurations: [ContextMenu.Action.Configuration], handler: ((@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void))?) async -> ContextMenu
}

public struct AnyContextMenuBuildable: ContextMenuBuildable {
	private let _configuration: @Sendable () async -> ContextMenu.Configuration
	private let _makeMenu: @Sendable ([ContextMenu.Action.Configuration], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextMenu
	
	public let base: any ContextMenuBuildable
	
	public var sections: [ContextMenu.Section] {
		base.sections
	}
	
	public func makeConfiguration() async -> ContextMenu.Configuration {
		await _configuration()
	}
	
	public func makeContextMenu(configurations: [ContextMenu.Action.Configuration], handler: (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextMenu {
		await _makeMenu(configurations, handler)
	}
	
	public init<Base: ContextMenuBuildable>(_ base: Base) {
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
	
	public var sections: [ContextMenu.Section] {
		[.remove, .queue, .favorite, .share, .library]
	}
	
	public func makeConfiguration() async -> ContextMenu.Configuration {
		.init { configurations, handler in
			let updatedSections = await updatedSections(from: sections, using: configurations)
			return ContextMenu(source: AnyContextMenuBuildable(self), sections: updatedSections, handler: handler)
		}
	}
	
	public func makeContextMenu(configurations: [ContextMenu.Action.Configuration], handler: (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) async -> ContextMenu {
		let config = await makeConfiguration()
		return await config.menuBuilder(configurations, handler)
	}
	
	private func updatedSections(
		from sections: [ContextMenu.Section],
		using configurations: [ContextMenu.Action.Configuration]
	) async -> [ContextMenu.Section] {
		var resultSections: [ContextMenu.Section] = []
		for section in sections {
			var updatedItems: [ContextMenu.Section.Item] = []
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
			
			let updatedSection = ContextMenu.Section(id: section.id, title: section.title, options: section.options, children: updatedItems)
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
			
			let handler: @Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void = { action, item in
				print("Selected ACTION: \(action.id) - Item: \(item.base)")
			}
			
			let addToLibraryConfig = ContextMenu.Action.Configuration(id: .addToLibrary) {
				[]
			} stateProvider: {
				.off
			}
			
			Task {
				let contextMenu = await song.makeContextMenu(
					configurations: [addToLibraryConfig],
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
	}
}
*/
