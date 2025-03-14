// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

final public class Action: NSObject {
    private let _action: () -> ()
    
    public init(action: @escaping () -> ()) {
        _action = action
        super.init()
    }
    
    @objc
    public func selector() {
        _action()
    }
}
