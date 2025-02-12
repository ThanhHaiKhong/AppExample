// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import TCAInitializableReducer

public protocol ExtraStateConstraints: Identifiable, Equatable, Sendable {
    
}

public protocol ExtraActionConstraints: Equatable, Sendable {
    
}

@Reducer
public struct ItemWithAdReducer<Content: TCAInitializableReducer, Ad: TCAInitializableReducer>: Sendable
where Content.State: Identifiable, Ad.State: Identifiable {

    @ObservableState
    public enum State: Identifiable {
        case content(Content.State)
        case ad(Ad.State)
        
        public var id: AnyHashable {
            switch self {
            case .content(let contentState):
                return contentState.id
            case .ad(let adState):
                return adState.id
            }
        }
    }
    
    public enum Action {
        case content(Content.Action)
        case ad(Ad.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.content, action: \.content) {
            Content()
        }
        
        Scope(state: \.ad, action: \.ad) {
            Ad()
        }
    }
    
    public init() {}
}

extension ItemWithAdReducer.State: Equatable where Content.State: ExtraStateConstraints, Ad.State: ExtraStateConstraints {
    
}

extension ItemWithAdReducer.Action: Equatable where Content.Action: ExtraActionConstraints, Ad.Action: ExtraActionConstraints {
    
}

extension ItemWithAdReducer.State: Sendable where Content.State: ExtraStateConstraints, Ad.State: ExtraStateConstraints {
    
}

extension ItemWithAdReducer.Action: Sendable where Content.Action: ExtraActionConstraints, Ad.Action: ExtraActionConstraints {
    
}
