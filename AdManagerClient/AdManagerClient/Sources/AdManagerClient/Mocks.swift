//
//  Mocks.swift
//  AdManagerClient
//
//  Created by Thanh Hai Khong on 4/2/25.
//

import ComposableArchitecture

extension AdManagerClient: TestDependencyKey {
    public static let testValue: AdManagerClient = {
        return Self()
    }()
    
    public static let previewValue: AdManagerClient = {
        return Self()
    }()
}
