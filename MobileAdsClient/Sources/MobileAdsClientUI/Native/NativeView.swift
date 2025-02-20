//
//  NativeAdView.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 6/2/25.
//

import ComposableArchitecture
import SwiftUI

public struct NativeView: UIViewRepresentable {
    
    private let store: StoreOf<Native>
    
    public init(store: StoreOf<Native>) {
        self.store = store
    }
    
    public func makeUIView(context: Context) -> CustomNativeAdView {
        return CustomNativeAdView()
    }
    
    public func updateUIView(_ nativeAdView: CustomNativeAdView, context: Context) {
        guard let nativeAd = store.nativeAd else {
            return
        }
        
        nativeAdView.configure(with: nativeAd)
        
        DispatchQueue.main.async {
            let totalHeight = nativeAdView.calculateTotalHeight()
            store.send(.updateAdHeight(totalHeight))
        }
    }
}
