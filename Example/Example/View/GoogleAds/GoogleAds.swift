//
//  GoogleAds.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/2/25.
//

import ComposableArchitecture
import TCAInitializableReducer
import MobileAdsClientUI
import SwiftUI
import Foundation

@Reducer
public struct GoogleAds: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var banners: IdentifiedArrayOf<Banner.State> = []
        public var anchoredBanner: Banner.State?
        public var items: IdentifiedArrayOf<ItemWithAdReducer<Article, Banner>.State> = []
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case banners(IdentifiedActionOf<Banner>)
        case items(IdentifiedActionOf<ItemWithAdReducer<Article, Banner>>)
        case anchoredBanner(Banner.Action)
        case onTask
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer() 
        
        Reduce { state, action in
            switch action {
            case .onTask:
                
                let staticSize: StandardSize = .banner
                let staticType = BannerType.static(staticSize)
                
                let inlineAdaptiveSize: InlineAdaptiveSize = .currentOrientationInlineAdaptiveBannerWidth(UIScreen.main.bounds.size.width - 40)
                let inlineType = BannerType.inlineAdaptive(inlineAdaptiveSize)
                var array: [Banner.State] = []
                
                for _ in 0..<5 {
                    let staticBanner = Banner.State(adUnitID: "ca-app-pub-3940256099942544/2435281174", type: inlineType, layer: .thick)
                    array.append(staticBanner)
                }
                
                state.banners = .init(uniqueElements: array.enumerated().map(\.element))
                
                let anchoredSize: AnchoredAdaptiveSize = .currentOrientationAnchoredAdaptiveBannerWidth(UIScreen.main.bounds.size.width - 40)
                let config: CollapsibleConfig = .init(isCollapsible: true, anchorPosition: .top)
                let anchoredType = BannerType.anchoredAdaptive(anchoredSize, collapsible: nil)
                let anchoredBanner = Banner.State(adUnitID: "ca-app-pub-3940256099942544/2435281174", type: anchoredType, layer: .thick)
                state.anchoredBanner = anchoredBanner
                
                var items: [ItemWithAdReducer<Article, Banner>.State] = []
                for index in 0..<15 {
                    let article: ItemWithAdReducer<Article, Banner>.State = .content(Article.State())
                    items.append(article)
                    if index.isMultiple(of: 3) {
                        let banner: ItemWithAdReducer<Article, Banner>.State = .ad(Banner.State(adUnitID: "ca-app-pub-3940256099942544/2435281174", type: inlineType, layer: .thick))
                        items.append(banner)
                    }
                }
                
                state.items = .init(uniqueElements: items.enumerated().map(\.element))
                
                return .none
                
            case .anchoredBanner:
                return .none
                
            case .banners:
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.banners, action: \.banners) {
            Banner()
        }
        .forEach(\.items, action: \.items) {
            ItemWithAdReducer()
        }
        .ifLet(\.anchoredBanner, action: \.anchoredBanner) {
            Banner()
        }
    }
        
    public init() { }
}

@Reducer
public struct Article: TCAInitializableReducer, Sendable {
    @ObservableState
    public struct State: Identifiable, Sendable, Equatable {
        public var id: String = UUID().uuidString
        public init() { }
    }
    
    public enum Action: BindableAction, Sendable, Equatable {
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

@Reducer
public struct ItemWithAdReducer<Content: TCAInitializableReducer, Ad: TCAInitializableReducer>: Sendable
where Content.State: Identifiable & Sendable & Equatable,
      Ad.State: Identifiable & Sendable & Equatable,
      Content.Action: Sendable & Equatable,
      Ad.Action: Sendable & Equatable {
    
    @ObservableState
    public enum State: Identifiable, Equatable {
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
    
    public enum Action: Equatable {
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
