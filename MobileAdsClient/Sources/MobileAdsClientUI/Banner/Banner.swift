//
//  Banner.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 6/2/25.
//

import ComposableArchitecture
import TCAInitializableReducer
import GoogleMobileAds

@Reducer
public struct Banner: TCAInitializableReducer, Sendable {
    @ObservableState
    public struct State: Identifiable, Sendable, Equatable {
        public var id : String = UUID().uuidString
        public let adUnitID: String
        public let adSize: AdSize
        public let type: BannerType
        public let layer: BannerLayer
        public var actualSize: CGSize = .zero
        public var isCollapsed: Bool = false
        
        public init(adUnitID: String, type: BannerType, layer: BannerLayer = .default, padding: BannerPadding = .none) {
            self.adUnitID = adUnitID
            self.type = type
            self.layer = layer
            
            switch type {
            case let .static(banner):
                self.adSize = banner.adSize
            case let .inlineAdaptive(banner):
                self.adSize = banner.adSize
            case let .anchoredAdaptive(banner, _):
                self.adSize = banner.adSize
            }
        }
    }
    
    public enum Action: Equatable, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case receivedActualSize(CGSize)
        case isCollapsed(Bool)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .receivedActualSize(size):
                state.actualSize = size
                return .none
                
            case let .isCollapsed(isCollapsed):
                state.isCollapsed = isCollapsed
                return .none
                
            default:
                return .none
            }
        }
    }
        
    public init() { }
}
