// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture

public protocol TCAInitializableReducer: Reducer {
    init()
}
