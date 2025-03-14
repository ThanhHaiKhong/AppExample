// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public protocol TransitionPresenter: AnyObject {
    
    var presentingView: UIView? { get }
    
    func didDismissBegin()
    
    func dismissProgress(_ progress: CGFloat)
    
    func willDismissEnd()
    
    func willPresentBegin()
    
    func didPresentBegin()
    
    func willPresentCancel()
    
    func presentProgress(_ progress: CGFloat)
    
    func willPresentEnd()
    
    func updateStatusBar(_ style: UIStatusBarStyle)
}

public extension TransitionPresenter {
    
    func willPresentBegin() { }
    
    func willPresentCancel() { }
    
    func didPresentBegin() { }
    
    func willPresentEnd() { }
    
    func presentProgress(_ progress: CGFloat) { }
    
    func didDismissBegin() { }
    
    func willDismissEnd() { }
    
    func dismissProgress(_ progress: CGFloat) { }
    
    func updateStatusBar(_ style: UIStatusBarStyle) { }
}
