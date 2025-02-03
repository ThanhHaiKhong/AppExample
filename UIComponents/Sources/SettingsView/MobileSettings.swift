//
//  MobileSettings.swift
//  MobilePlatform
//
//  Created by Thanh Hai Khong on 3/10/24.
//

import ComposableArchitecture
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@Reducer
public struct MobileSettings {
    @ObservableState
    public struct State: Equatable {
        public let appID: String
        
        public init(appID: String) {
            self.appID = appID
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
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .shareButtonTapped:
                guard let url = URL(string: "https://apps.apple.com/app/id\(state.appID)") else {
                    return .none
                }
                
                return .run { send in
                    let activityViewController = await UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let topMostViewController = await UIApplication.shared.topMostViewController {
                        await topMostViewController.present(activityViewController, animated: true, completion: nil)
                    }
                }
            case .rateButtonTapped:
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(state.appID)?action=write-review") else {
                    return .none
                }
                
                return .run { send in
                    await UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                }
            case .contactButtonTapped:
                return .none
            case .reportButtonTapped:
                return .none
            case .requestButtonTapped:
                return .none
            case .privacyPolicyButtonTapped:
                guard let url = URL(string: "http://orlproducts.com/privacy.html") else {
                    return .none
                }
                
                return .run { send in
                    await UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .termsOfServiceButtonTapped:
                guard let url = URL(string: "http://orlproducts.com/terms.html") else {
                    return .none
                }
                
                return .run { send in
                    await UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    public init () {
        
    }
}
