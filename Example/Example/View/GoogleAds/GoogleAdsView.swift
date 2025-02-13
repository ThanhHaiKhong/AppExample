//
//  GoogleAdsView.swift
//  Example
//
//  Created by Thanh Hai Khong on 6/2/25.
//

import ComposableArchitecture
import MobileAdsClientUI
import GoogleMobileAds
import UIComponents
import Foundation
import SwiftUI

struct GoogleAdsView: View {
    
    @Perception.Bindable var store: StoreOf<GoogleAds>
    
    var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.scope(state: \.banners, action: \.banners)) { store in
                    BannerAdView(store: store)
                        .frame(width: store.actualSize.width, height: store.actualSize.height)
                }
                .onDelete { indexSet in
                    
                }
                
                ForEach(store.scope(state: \.items, action: \.items)) { itemStore in
                    switch(itemStore.state) {
                    case .content:
                        if let store = itemStore.scope(state: \.content, action: \.content) {
                            ArticleView(store: store)
                        }
                        
                    case .ad:
                        if let store = itemStore.scope(state: \.ad, action: \.ad) {
                            BannerAdView(store: store)
                                .frame(width: store.actualSize.width, height: store.actualSize.height)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let store = store.scope(state: \.anchoredBanner, action: \.anchoredBanner) {
                    BannerAdView(store: store)
                        .frame(width: store.actualSize.width, height: store.actualSize.height)
                }
            }
            .task {
                store.send(.onTask)
            }
        }
    }
}

#Preview {
    let store = Store(initialState: GoogleAds.State()) {
        GoogleAds()
    }
    
    GoogleAdsView(store: store)
}
