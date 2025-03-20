// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol TCADismissableAction {
    static func dismiss() -> Self
}

public protocol TCAFeatureAction {
    associatedtype ViewAction
    associatedtype DelegateAction
    associatedtype InternalAction
    
    static func view(_: ViewAction) -> Self
    static func `internal`(_: InternalAction) -> Self
    static func delegate(_: DelegateAction) -> Self
}

extension TCAFeatureAction where ViewAction: TCADismissableAction {
    static func dismiss() -> Self {
        return view(ViewAction.dismiss())
    }
}

public func canDismissRuntime<Action: TCAFeatureAction>(_ action: Action) -> Bool {
    return Action.ViewAction.self is TCADismissableAction.Type
}
