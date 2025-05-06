//
//  SceneDelegate.swift
//  MediaPlayerPreview
//
//  Created by Thanh Hai Khong on 24/4/25.
//

import ComposableArchitecture
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
		
		let store = Store(initialState: PlayerStore.State()) {
			PlayerStore()
		}
		
		let _ = Store(initialState: EqualizerStore.State()) {
			EqualizerStore()
		}
        
        let window = UIWindow(windowScene: windowScene)
		window.rootViewController = PlayerViewController(store: store)
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}

