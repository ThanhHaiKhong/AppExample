//
//  UIViewExtensions.swift
//  UIExtensions
//
//  Created by Thanh Hai Khong on 28/6/25.
//

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
extension UIView {
	
	public func addBlur(style: UIBlurEffect.Style = .light, cornerRadius: CGFloat = 0) {
		if subviews.contains(where: { $0 is UIVisualEffectView }) {
			return
		}
		
		let blurEffect = UIBlurEffect(style: style)
		let blurView = UIVisualEffectView(effect: blurEffect)
		
		blurView.frame = bounds
		blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		if cornerRadius > 0 {
			blurView.layer.cornerRadius = cornerRadius
			blurView.clipsToBounds = true
		}
		
		addSubview(blurView)
		sendSubviewToBack(blurView)
	}
	
	public func removeBlur() {
		subviews
			.filter { $0 is UIVisualEffectView }
			.forEach { $0.removeFromSuperview() }
	}
}
#endif
