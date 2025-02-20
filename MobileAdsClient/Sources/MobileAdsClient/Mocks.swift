//
//  Mocks.swift
//  MobileAdsClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture

extension MobileAdsClient: TestDependencyKey {
    public static let testValue: MobileAdsClient = {
        return Self()
    }()
    
    public static let previewValue: MobileAdsClient = {
        return Self()
    }()
}
