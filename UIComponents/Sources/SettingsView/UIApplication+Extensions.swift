//
//  UIApplication+Extensions.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 10/10/24.
//

import UIKit

@available(iOS 16.0, *)
extension UIApplication {
    public var topMostViewController: UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
        guard let windowScene = scene as? UIWindowScene else { return nil }
        var topMostViewController: UIViewController? = windowScene.keyWindow?.rootViewController
        while topMostViewController?.presentedViewController != nil {
            topMostViewController = topMostViewController?.presentedViewController
        }
        return topMostViewController
    }
}
