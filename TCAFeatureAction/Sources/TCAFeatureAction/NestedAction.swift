//
//  NestedAction.swift
//  TCAFeatureAction
//
//  Created by Thanh Hai Khong on 6/12/24.
//

import ComposableArchitecture

@Reducer
public struct NestedAction<State, Action, ChildAction> {
    @usableFromInline
    let toChildAction: AnyCasePath<Action, ChildAction>
    
    @usableFromInline
    let toEffect: (inout State, ChildAction) -> Effect<Action>
    
    @inlinable
    public init(_ toChildAction: CaseKeyPath<Action, ChildAction>, toEffect: @escaping (inout State, ChildAction) -> Effect<Action>) {
        self.toChildAction = AnyCasePath(toChildAction)
        self.toEffect = toEffect
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        guard let childAction = self.toChildAction.extract(from: action) else {
            return .none
        }
        return toEffect(&state, childAction)
    }
}
