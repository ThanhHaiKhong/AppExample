//
//  GoogleAdMobUI.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 24/1/25.
//

import GoogleMobileAds
import SwiftUI
import UIKit

public struct BannerAdView: UIViewRepresentable {
    private let adUnitID: String
    private let adSize: AdSize
    
    public init(adUnitID: String, size: CGSize) {
        self.adUnitID = adUnitID
        self.adSize = adSizeFor(cgSize: size)
    }
    
    public func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        view.addSubview(blurEffectView)
        view.insertSubview(context.coordinator.bannerView, aboveSubview: blurEffectView)
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    public func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    
    public class BannerCoordinator: NSObject, BannerViewDelegate {
        
        @MainActor
        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView(adSize: parent.adSize)
            banner.adUnitID = parent.adUnitID
            let extras = Extras()
            extras.additionalParameters = ["collapsible" : "bottom"]
            let request = Request()
            // request.register(extras)
            banner.load(request)
            banner.delegate = self
            return banner
        }()
        
        private let parent: BannerAdView
        
        public init(_ parent: BannerAdView) {
            self.parent = parent
        }
    }
}
