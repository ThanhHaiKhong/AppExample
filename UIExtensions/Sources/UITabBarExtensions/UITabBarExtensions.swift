//
//  UITabBarExtensions.swift
//  UIExtensions
//
//  Created by Thanh Hai Khong on 23/5/25.
//

#if canImport(UIKit)
import UIKit
#endif

import UIImageExtensions
import Foundation

#if os(iOS)
extension UITabBar {
	
	public static var height: CGFloat {
		for scene in UIApplication.shared.connectedScenes {
			if let windowScene = scene as? UIWindowScene {
				for window in windowScene.windows {
					if let tabBar = window.rootViewController?.tabBarController?.tabBar {
						return tabBar.frame.height
					}
				}
			}
		}
		return 49 // Default fallback height
	}
	
	public func setTransparentBackground() {
		backgroundImage = UIImage()
		shadowImage = UIImage()
		backgroundColor = .clear
		isTranslucent = true
	}
	
	public func setSolidBackground(color: UIColor) {
		backgroundImage = UIImage(color: color)
		shadowImage = UIImage()
		isTranslucent = false
	}
}

extension UITabBarController {
	
	public func setTabBarHidden(_ hidden: Bool, animated: Bool = true) {
		let height = tabBar.frame.size.height
		let offsetY = hidden ? height : -height
		
		UIView.animate(withDuration: animated ? 0.3 : 0.0) {
			self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
		}
	}
}

extension UITabBarController {
	public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		guard let index = tabBar.items?.firstIndex(of: item),
			  index == selectedIndex else { return }
		NotificationCenter.default.post(name: .tabBarRepeatedTap, object: nil)
	}
}

extension UIApplication {
	
	public static var safeTabBarHeight: CGFloat {
		let keyWindow = UIApplication.shared.connectedScenes
			.compactMap { ($0 as? UIWindowScene)?.keyWindow }
			.first
		return keyWindow?.rootViewController?.tabBarController?.tabBar.frame.height ?? 49
	}
}
#endif

extension Notification.Name {
	public static let tabBarRepeatedTap = Notification.Name("tabBarRepeatedTap")
}
