//
//  AppTrackingClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 27/1/25.
//

import ComposableArchitecture
import MobileAdsClient
import InAppPurchaseClient
import AppTrackingClient

@DependencyClient
public struct MobilePlatformClient: Sendable {
    
}

extension MobilePlatformClient: DependencyKey {
    public static let liveValue: MobilePlatformClient = {
        return MobilePlatformClient(
            
        )
    }()
}

extension MobilePlatformClient: TestDependencyKey {
    public static var testValue: MobilePlatformClient {
        MobilePlatformClient()
    }
}

extension DependencyValues {
    public var mobilePlatformClient: MobilePlatformClient {
        get { self[MobilePlatformClient.self] }
        set { self[MobilePlatformClient.self] = newValue }
    }
}
