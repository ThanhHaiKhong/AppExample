//
//  Mocks.swift
//  PhotosClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import ComposableArchitecture

extension DependencyValues {
	public var photosClient: PhotosClient {
		get { self[PhotosClient.self] }
		set { self[PhotosClient.self] = newValue }
	}
}

extension PhotosClient: TestDependencyKey {
    public static var testValue: PhotosClient {
        PhotosClient()
    }
    
    public static var previewValue: PhotosClient {
        PhotosClient()
    }
}
