//
//  GoogleAds.swift
//  Example
//
//  Created by Thanh Hai Khong on 7/2/25.
//

import ComposableArchitecture
import MobileAdsClientUI
import SwiftUI

@Reducer
public struct GoogleAds: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var banners: IdentifiedArrayOf<Banner.State> = []
        public var anchoredBanner: Banner.State?
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case banners(IdentifiedActionOf<Banner>)
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
                
                let inlineAdaptiveSize: InlineAdaptiveSize = .currentOrientationInlineAdaptiveBannerWidth(UIScreen.main.bounds.size.width - 60)
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
        .ifLet(\.anchoredBanner, action: \.anchoredBanner) {
            Banner()
        }
    }
        
    public init() { }
}
