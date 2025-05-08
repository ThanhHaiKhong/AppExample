//
//  AppSceneDelegate.swift
//  Example
//
//  Created by Thanh Hai Khong on 5/2/25.
//

import ComposableArchitecture
import MobileAdsClient
import Combine
import SwiftUI
import UIKit

class AppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    public var window: UIWindow?
    private let publisher = AppSceneEventPublisher()
    
    private lazy var photoViewController: PhotoViewController = {
        let store = Store(initialState: PhotoList.State()) {
            PhotoList()
        }
        return PhotoViewController(store: store)
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = AppUIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: photoViewController)
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        publisher.phase = .active
        /*
        Task {
            let mobileAds = DependencyValues._current.mobileAdsClient
            let appOpen: MobileAdsClient.AdType = .appOpen("ca-app-pub-5018745952984578/9860114504")   // com.orientpro.PhotoCompress ca-app-pub-5018745952984578~9939657844
            let rules: [MobileAdsClient.AdRule] = []
            
            if try await mobileAds.isUserSubscribed() {
                
            } else if try await mobileAds.shouldShowAd(appOpen, rules) {
                try await mobileAds.requestTrackingAuthorizationIfNeeded()
                try await mobileAds.showAd()
            }
        }
        */
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        publisher.phase = .background
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        publisher.phase = .inactive
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            publisher.openURL = url
        }
    }
}

class AppUIWindow: UIWindow {
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        runWithOtherViews(except: subview) { view in
            view.isUserInteractionEnabled = false
        }
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        
        runWithOtherViews(except: subview) { view in
            view.isUserInteractionEnabled = true
        }
    }
    
    private func runWithOtherViews(except subview: UIView, block: (UIView) -> Void) {
        if type(of: subview) == NSClassFromString("_UIContextMenuContainerView") {
            self.subviews.filter { $0 != subview }.forEach { view in
                block(view)
            }
        }
    }
}

class AppSceneEventPublisher: ObservableObject {
    @Published var phase: ScenePhase = .inactive
    @Published var openURL: URL?
}
