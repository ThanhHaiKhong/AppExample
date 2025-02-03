// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol TCAFeatureAction {
    associatedtype ViewAction
    associatedtype DelegateAction
    associatedtype InternalAction
    
    static func view(_: ViewAction) -> Self
    static func `internal`(_: InternalAction) -> Self
    static func delegate(_: DelegateAction) -> Self
}
