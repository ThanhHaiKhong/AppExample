// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKitPreviews
import UIKit
import SwiftUI

public protocol ContextMenuBuildable: Sendable {
	var configuration: ContextMenu.Configuration { get }
	func makeContextMenu(sections: [ContextMenu.Section], handler: ((@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void))?) -> ContextMenu
}

public struct AnyContextMenuBuildable: ContextMenuBuildable {
	private let _configuration: @Sendable () -> ContextMenu.Configuration
	private let _makeMenu: @Sendable ([ContextMenu.Section], (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) -> ContextMenu
	
	public let base: any ContextMenuBuildable
	
	public var configuration: ContextMenu.Configuration {
		_configuration()
	}
	
	public func makeContextMenu(sections: [ContextMenu.Section], handler: (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) -> ContextMenu {
		_makeMenu(sections, handler)
	}
	
	public init<Base: ContextMenuBuildable>(_ base: Base) {
		self.base = base
		_configuration = { base.configuration }
		_makeMenu = { sections, handler in
			base.makeContextMenu(sections: sections, handler: handler)
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
	
	public var configuration: ContextMenu.Configuration {
		.init { sections, handler in
			ContextMenu(source: AnyContextMenuBuildable(self), sections: sections, handler: handler)
		}
	}
	
	public func makeContextMenu(sections: [ContextMenu.Section], handler: (@Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void)?) -> ContextMenu {
		configuration.menuBuilder(sections, handler)
	}
}

struct ContextMenuViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let song = Song(
				id: "1",
				title: "Song Title",
				artist: "Artist Name",
				artworkURL: URL(string: "https://example.com/artwork.jpg")
			)
			
			let handler: @Sendable (ContextMenu.Action, AnyContextMenuBuildable) -> Void = { action, item in
				print("Selected ACTION: \(action.id) - Item: \(item.base)")
			}
			
			let contextMenu = song.makeContextMenu(sections: [
				.remove,
				.queue,
				.favorite,
				.share,
				.library,
			], handler: handler)
			
			let menuButton = UIButton(type: .system)
			menuButton.translatesAutoresizingMaskIntoConstraints = false
			menuButton.setTitle("Show Context Menu", for: .normal)
			menuButton.menu = contextMenu.toUIMenu()
			menuButton.showsMenuAsPrimaryAction = true
			
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
