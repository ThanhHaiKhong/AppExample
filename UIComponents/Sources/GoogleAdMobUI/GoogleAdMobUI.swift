//
//  GoogleAdMobUI.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 24/1/25.
//

import GoogleMobileAds
import SwiftUI
import UIKit

public struct BannerView: UIViewRepresentable {
    private let adUnitID: String
    private let adSize: GADAdSize
    
    public init(adUnitID: String, size: CGSize) {
        self.adUnitID = adUnitID
        self.adSize = GADAdSizeFromCGSize(size)
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
    
    public class BannerCoordinator: NSObject, GADBannerViewDelegate {
        
        @MainActor
        private(set) lazy var bannerView: GADBannerView = {
            let banner = GADBannerView(adSize: parent.adSize)
            banner.adUnitID = parent.adUnitID
            let extras = GADExtras()
            extras.additionalParameters = ["collapsible" : "bottom"]
            let request = GADRequest()
            // request.register(extras)
            banner.load(request)
            banner.delegate = self
            return banner
        }()
        
        private let parent: BannerView
        
        public init(_ parent: BannerView) {
            self.parent = parent
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            
        }
        
        public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            
        }
    }
}
