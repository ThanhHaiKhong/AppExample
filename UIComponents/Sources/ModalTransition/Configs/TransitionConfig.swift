// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public struct TransitionConfig {
    public var presentDuration: TimeInterval
    public var presentResize: TimeInterval
    public var presentStatusBar: TimeInterval
    
    public var dismissDuration: TimeInterval
    public var dismissResize: TimeInterval
    public var dismissBlur: TimeInterval
    public var dismissStatusBar: TimeInterval
    public var dismissFade: TimeInterval
    
    public var dismissThreshold: CGFloat
    public var cancelResize: TimeInterval
    public var backgroundColor: UIColor
    
    public init(
        presentDuration: TimeInterval = 0.7,
        presentResize: TimeInterval = 0.8,
        presentStatusBar: TimeInterval = 0.3,
        dismissDuration: TimeInterval = 0.5,
        dismissResize: TimeInterval = 0.4,
        dismissBlur: TimeInterval = 0.2,
        dismissStatusBar: TimeInterval = 0.3,
        dismissFade: TimeInterval = 0.1,
        dismissThreshold: CGFloat = 0.2,
        cancelResize: TimeInterval = 0.3,
        backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    ) {
        self.presentDuration = presentDuration
        self.presentResize = presentResize
        self.presentStatusBar = presentStatusBar
        self.dismissDuration = dismissDuration
        self.dismissResize = dismissResize
        self.dismissBlur = dismissBlur
        self.dismissStatusBar = dismissStatusBar
        self.dismissFade = dismissFade
        self.dismissThreshold = dismissThreshold
        self.cancelResize = cancelResize
        self.backgroundColor = backgroundColor
    }
}
