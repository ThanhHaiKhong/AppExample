//
//  Mocks.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import Dependencies

extension DependencyValues {
	public var nativeAdClient: NativeAdClient {
		get { self[NativeAdClient.self] }
		set { self[NativeAdClient.self] = newValue }
	}
}

extension NativeAdClient: TestDependencyKey {
    public static let testValue: NativeAdClient = {
        return Self()
    }()
    
    public static let previewValue: NativeAdClient = {
        return Self()
    }()
}
