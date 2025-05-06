//
//  GradientBlurView.swift
//  Example
//
//  Created by Thanh Hai Khong on 20/3/25.
//

import UIKit

public class GradientBlurView: UIView {
    private let visualEffectView: UIVisualEffectView
    private let gradientLayer = CAGradientLayer()
    private let reverse: Bool
    
    public init(effect: UIBlurEffect.Style = .light, startPoint: CGFloat = 0.0, endPoint: CGFloat = 1.0, reverse: Bool = false) {
        self.reverse = reverse
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        
        super.init(frame: .zero)
        
        setupView(startPoint: startPoint, endPoint: endPoint, reverse: reverse)
    }
    
    public required init?(coder: NSCoder) {
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        reverse = false
        
        super.init(coder: coder)
        
        setupView(startPoint: 0.0, endPoint: 1.0, reverse: reverse)
    }
    
    private func setupView(startPoint: CGFloat, endPoint: CGFloat, reverse: Bool) {
        addSubview(visualEffectView)
        applyGradientMask(startPoint: startPoint, endPoint: endPoint, reverse: reverse)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = bounds
        applyGradientMask(startPoint: gradientLayer.startPoint.y, endPoint: gradientLayer.endPoint.y, reverse: reverse)
    }
    
    public func updateBlurEffect(effect: UIBlurEffect.Style, startPoint: CGFloat, endPoint: CGFloat, reverse: Bool) {
        visualEffectView.effect = UIBlurEffect(style: effect)
        applyGradientMask(startPoint: startPoint, endPoint: endPoint, reverse: reverse)
    }
    
    private func applyGradientMask(startPoint: CGFloat, endPoint: CGFloat, reverse: Bool) {
        gradientLayer.frame = bounds
        gradientLayer.colors = reverse ? [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ] : [
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: startPoint)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: endPoint)

        let maskView = UIView(frame: bounds)
        maskView.layer.addSublayer(gradientLayer)
        visualEffectView.mask = maskView
    }
}
