//
//  AppDelegate.swift
//  Example
//
//  Created by Thanh Hai Khong on 5/2/25.
//

import UserNotifications
import FirebaseCore
import UIKit
import MCP

@main
class AppDelegate: UIResponder {
    public var backgroundSessionCompletionHandler: (() -> Void)?
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = AppSceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in
            
        })
        
        application.registerForRemoteNotifications()
		
		let client = Client(name: "AppExample", version: "1.0.0")
		let transport = StdioTransport()
		Task {
			do {
				let result = try await client.connect(transport: transport)
				
				if result.capabilities.tools != nil {
					print("Tools are supported")
				} else {
					print("Tools are not supported")
				}
			} catch {
				print("Failed to register client: \(error)")
			}
		}
		
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func applicationDidBecomeActive() {
        
    }
    
    func applicationDidEnterBackground() {
        
    }
    
    func applicationWillEnterForeground() {
        
    }
    
    func applicationWillTerminate() {
        
    }
}

// MARK: - UNUserNotificationCenterDelegate + MessagingDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
    }
}
