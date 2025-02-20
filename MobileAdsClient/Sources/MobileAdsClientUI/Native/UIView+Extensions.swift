//
//  UIView+Extensions.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 17/2/25.
//

import UIKit

extension UIView {
    
    public func addBlur(style: UIBlurEffect.Style = .light, cornerRadius: CGFloat = 0) {
        if self.subviews.contains(where: { $0 is UIVisualEffectView }) {
            return
        }
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.clipsToBounds = true
        }
        
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
    }
    
    public func removeBlur() {
        self.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }
    }
}
