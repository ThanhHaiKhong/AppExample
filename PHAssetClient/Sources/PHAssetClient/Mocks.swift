//
//  Mocks.swift
//  PHAssetClient
//
//  Created by Thanh Hai Khong on 10/4/25.
//

import Dependencies

extension DependencyValues {
    public var phAssetClient: PHAssetClient {
        get { self[PHAssetClient.self] }
        set { self[PHAssetClient.self] = newValue }
    }
}

extension PHAssetClient: TestDependencyKey {
    public static var testValue: PHAssetClient {
        PHAssetClient()
    }
    
    public static var previewValue: PHAssetClient {
        PHAssetClient()
    }
}
