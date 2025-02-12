//
//  File.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 6/2/25.
//

import ComposableArchitecture
import GoogleMobileAds

@Reducer
public struct Native: Sendable {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            return .none
        }
    }
        
    public init() { }
}

