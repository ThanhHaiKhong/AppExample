//
//  MobileSettings.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 3/10/24.
//

import ComposableArchitecture
import UIKit

@available(iOS 16.0, *)
@Reducer
public struct MobileSettings: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let appInfo: AppInfo
        
        public init(appInfo: AppInfo) {
            self.appInfo = appInfo
        }
        
        public struct AppInfo: Equatable, Sendable {
            public let appID: String
            public let name: String
            public let version: String
            public let build: String?
            public let supportEmail: String
            
            public init(appID: String, name: String, version: String, build: String? = nil, supportEmail: String) {
                self.appID = appID
                self.name = name
                self.version = version
                self.build = build
                self.supportEmail = supportEmail
            }
        }
    }
    
    public enum Action: Equatable {
        case shareButtonTapped
        case rateButtonTapped
        case contactButtonTapped
        case reportButtonTapped
        case requestButtonTapped
        case privacyPolicyButtonTapped
        case termsOfServiceButtonTapped
        case dismissButtonTapped
    }
    
    @Dependency(\.openURL) var openURL
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .shareButtonTapped:
                guard let url = URL(string: "https://apps.apple.com/app/id\(state.appInfo.appID)") else {
                    return .none
                }
                
                return .run { send in
                    let activityViewController = await UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let topMostViewController = await UIApplication.shared.topMostViewController {
                        await topMostViewController.present(activityViewController, animated: true, completion: nil)
                    }
                }
                
            case .rateButtonTapped:
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(state.appInfo.appID)?action=write-review") else {
                    return .none
                }
                
                return .run { send in
                    await openURL(writeReviewURL)
                }
                
            case .contactButtonTapped:
                return .run { [info = state.appInfo] send in
                    let subject = "General Inquiry"
                    let body = "Hello, I need help with..."
                    let appInfo = """
                        ===========================
                        📱 App: \(info.name)
                        🏷 Version: \(info.version)
                        ===========================
                        """
                    let fullBody = "\(body)\n\n\(appInfo)"
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedBody = fullBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    if let url = URL(string: "mailto:\(info.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)") {
                        await openURL(url)
                    }
                }
                
            case .reportButtonTapped:
                return .run { [info = state.appInfo] send in
                    let subject = "Bug Report"
                    let body = "I found a problem with..."
                    let appInfo = """
                        ===========================
                        📱 App: \(info.name)
                        🏷 Version: \(info.version)
                        ===========================
                        """
                    let fullBody = "\(body)\n\n\(appInfo)"
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedBody = fullBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    if let url = URL(string: "mailto:\(info.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)") {
                        await openURL(url)
                    }
                }
                
            case .requestButtonTapped:
                return .run { [info = state.appInfo] send in
                    let subject = "Feature Request"
                    let body = "I would love to see..."
                    let appInfo = """
                        ===========================
                        📱 App: \(info.name)
                        🏷 Version: \(info.version)
                        ===========================
                        """
                    let fullBody = "\(body)\n\n\(appInfo)"
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedBody = fullBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    if let url = URL(string: "mailto:\(info.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)") {
                        await openURL(url)
                    }
                }
                
            case .privacyPolicyButtonTapped:
                guard let url = URL(string: "http://orlproducts.com/privacy.html") else {
                    return .none
                }
                
                return .run { send in
                    await openURL(url)
                }
            case .termsOfServiceButtonTapped:
                guard let url = URL(string: "http://orlproducts.com/terms.html") else {
                    return .none
                }
                
                return .run { send in
                    await openURL(url)
                }
                
            case .dismissButtonTapped:
                return .none
            }
        }
    }
    
    public init () { }
}
