//
//  Live.swift
//  PhotosClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import ComposableArchitecture
import PhotosClient
import Photos

extension PhotosClient: DependencyKey {
    public static let liveValue: PhotosClient = {
        let actor = PhotoLibraryActor()
        return .init(
            authorizationStatus: {
                await actor.authorizationStatus()
            },
            fetchAssets: { category in
                try await actor.fetchAssets(category: category)
            },
            observeChanges: { category in
                await actor.observeChanges(category: category)
            },
            saveImages: { paths in
                try await actor.saveImages(paths: paths)
            }
        )
    }()
}
