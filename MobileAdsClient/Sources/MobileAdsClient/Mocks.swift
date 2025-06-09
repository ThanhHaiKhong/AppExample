//
//  Mocks.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture

extension DependencyValues {
	public var mobileAdsClient: MobileAdsClient {
		get { self[MobileAdsClient.self] }
		set { self[MobileAdsClient.self] = newValue }
	}
}

extension MobileAdsClient: TestDependencyKey {
    public static let testValue: MobileAdsClient = {
        return Self()
    }()
    
    public static let previewValue: MobileAdsClient = {
        return Self()
    }()
}
