//
//  TransitionableView.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 13/3/25.
//

import Foundation
import UIKit

public protocol TransitionableView: AnyObject {
    
    var modalInteractor: InteractiveModalTransition? { get }
    
    var isModalTransitionEnabled: Bool { get }
    
    var transitionConfig: TransitionConfig { get }
    
    func willPresentBegin(from cardView: UIView)
    
    func didPresentBegin()
    
    func presentProgress(_ progress: CGFloat)
    
    func willPresentEnd()
    
    func willDismissBegin()
    
    func didDismissBegin()
    
    func willPresentCancel()
    
    func dismissProgress(_ progress: CGFloat)
    
    func willDismissEnd()
    
    func updateStatusBar(_ style: UIStatusBarStyle)
}

public extension TransitionableView {
    var isModalTransitionEnabled: Bool {
        true
    }
    
    var transitionConfig: TransitionConfig {
        return .init()
    }
    
    func willPresentBegin(from cardView: UIView) {
        
    }
    
    func didPresentBegin() {
        
    }
    
    func willPresentEnd() {
        
    }
    
    func presentProgress(_ progress: CGFloat) {
        
    }
    
    func willDismissBegin() {
        
    }
    
    func willPresentCancel() {
        
    }
    
    func didDismissBegin() {
        
    }
    
    func willDismissEnd() {
        
    }
    
    func dismissProgress(_ progress: CGFloat) {
        
    }
    
    func updateStatusBar(_ style: UIStatusBarStyle) {
        
    }
}
