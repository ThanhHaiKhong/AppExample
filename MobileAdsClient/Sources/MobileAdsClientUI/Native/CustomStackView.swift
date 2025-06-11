//
//  CustomStackView.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 18/2/25.
//

import UIKit

public class CustomStackView: UIStackView {
    private var viewsOrder: [UIView] = []
    
    public override func addArrangedSubview(_ view: UIView) {
        if !viewsOrder.contains(view) {
            viewsOrder.append(view)
        }
		setCustomSpacing(8, after: view)
        super.addArrangedSubview(view)
    }
    
    public override func removeArrangedSubview(_ view: UIView) {
        view.isHidden = true
		setCustomSpacing(0, after: view)
        super.removeArrangedSubview(view)
    }
    
    public func setVisibility(for view: UIView, isVisible: Bool) {
        if isVisible {
            if !arrangedSubviews.contains(view) {
                if let index = viewsOrder.firstIndex(of: view), index < arrangedSubviews.count {
                    insertArrangedSubview(view, at: index)
                } else {
                    addArrangedSubview(view)
                }
            }
            view.isHidden = false
        } else {
            removeArrangedSubview(view)
        }
    }
}
