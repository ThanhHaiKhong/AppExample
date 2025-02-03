//
//  MobileAdsClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 27/1/25.
//

import ComposableArchitecture
import AppTrackingTransparency

@DependencyClient
public struct AppTrackingClient: Sendable {
    public var requestTrackingAuthorization: @Sendable () async -> ATTrackingManager.AuthorizationStatus = {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}

extension AppTrackingClient: DependencyKey {
    public static let liveValue: AppTrackingClient = {
        return Self()
    }()
}

extension AppTrackingClient: TestDependencyKey {
    public static let testValue: AppTrackingClient = {
        return Self()
    }()
}

extension DependencyValues {
    public var appTrackingClient: AppTrackingClient {
        get { self[AppTrackingClient.self] }
        set { self[AppTrackingClient.self] = newValue }
    }
}
