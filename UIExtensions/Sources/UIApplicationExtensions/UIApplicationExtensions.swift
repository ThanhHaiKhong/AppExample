//
//  UIApplicationExtensions.swift
//  UIExtensions
//
//  Created by Thanh Hai Khong on 11/6/25.
//

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
extension UIApplication {
	public static var keyWindow: UIWindow? {
		shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
			.first?.windows
			.first(where: { $0.isKeyWindow })
	}
	
	public static var rootViewController: UIViewController? {
		keyWindow?.rootViewController
	}
	
	public static var topMostViewController: UIViewController? {
		var topController = rootViewController
		while let presentedViewController = topController?.presentedViewController {
			topController = presentedViewController
		}
		return topController
	}
}
#endif
