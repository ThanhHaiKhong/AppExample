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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        /*
        let hostingViewController = UIHostingController(rootView: SubscriptionView(store: Store(
            initialState: Subscriptions.State()) {
                Subscriptions()
            }
        ))
        */
        
        let hostingViewController = UIHostingController(rootView: GoogleAdsView(store: Store(
            initialState: GoogleAds.State()) {
                GoogleAds()
            }
        ))
        
        let window = AppUIWindow(windowScene: windowScene)
        window.rootViewController = hostingViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        publisher.phase = .active
        
        Task {
            let adManager = DependencyValues._current.mobileAdsClient
            let appOpen: MobileAdsClient.AdType = .appOpen("ca-app-pub-3940256099942544/5575463023")
            let rules: [MobileAdsClient.AdRule] = []
            
            if try await adManager.isUserSubscribed() {
                
            } else if try await adManager.shouldShowAd(appOpen, rules) {
                try await adManager.requestTrackingAuthorizationIfNeeded()
                try await adManager.showAd()
            }
        }
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

struct CustomOpenURL: ViewModifier {
    @EnvironmentObject var scenePhase: AppSceneEventPublisher
    
    let action: (URL) -> Void
    
    func body(content: Content) -> some View {
        content.onReceive(scenePhase.$openURL) { url in
            if let url = url {
                action(url)
            }
        }
    }
}

extension View {
    func onCustomOpenURL(perform action: @escaping (URL) -> Void) -> some View {
        self.modifier(CustomOpenURL(action: action))
    }
}
