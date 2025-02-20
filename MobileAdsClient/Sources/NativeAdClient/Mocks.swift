//
//  Mocks.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import ComposableArchitecture

extension NativeAdClient: TestDependencyKey {
    public static let testValue: NativeAdClient = {
        return Self()
    }()
    
    public static let previewValue: NativeAdClient = {
        return Self()
    }()
}
