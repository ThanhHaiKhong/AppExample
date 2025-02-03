//
//  PhotoLibraryClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 23/1/25.
//

import ComposableArchitecture
import PHAssetExtensions
import Combine
import Photos

@DependencyClient
public struct PhotoLibraryClient: Sendable {
    public var fetchAssets: @Sendable () async throws -> [PHAsset]
    public var observeChanges: @Sendable () async throws -> AsyncStream<[PHAsset]>
}

extension PhotoLibraryClient: DependencyKey {
    public static var liveValue: PhotoLibraryClient {
        let actor = PhotoLibraryActor()
        return PhotoLibraryClient(
            fetchAssets: {
                return try await actor.fetchAssets()
            },
            observeChanges: {
                return await actor.observeChanges()
            }
        )
    }
    
    public final actor PhotoLibraryActor {
        
        // MARK: - Private Properties
        
        private let observer = PhotoLibraryObserver()
        
        // MARK: - Public Methods
        
        public func fetchAssets() async throws -> [PHAsset] {
            try await observer.fetchAssets()
        }
        
        public func observeChanges() -> AsyncStream<[PHAsset]> {
            observer.observeChanges()
        }
        
        private final class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver, @unchecked Sendable {
            private var fetchResult: PHFetchResult<PHAsset>?
            private var continuation: AsyncStream<[PHAsset]>.Continuation?
            private var hasChanges = false
            
            override init() {
                super.init()
                PHPhotoLibrary.shared().register(self)
            }
            
            deinit {
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                continuation?.finish()
            }
            
            public func fetchAssets() async throws -> [PHAsset] {
                return try await withCheckedThrowingContinuation { continuation in
                    fetchResult = PHAsset.fetchAssets(with: .image, options: .all)
                    
                    if let fetchResult {
                        let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
                        continuation.resume(returning: assets)
                    } else {
                        continuation.resume(throwing: NSError(domain: "PhotoLibraryClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch assets"]))
                    }
                }
            }
            
            public func observeChanges() -> AsyncStream<[PHAsset]> {
                AsyncStream { continuation in
                    self.continuation = continuation
                    
                    if hasChanges, let fetchResult = fetchResult {
                        let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
                        continuation.yield(assets)
                    }
                    
                    continuation.onTermination = { _ in
                        self.continuation = nil
                    }
                }
            }
            
            func photoLibraryDidChange(_ changeInstance: PHChange) {
                guard let fetchResult = fetchResult,
                      let changes = changeInstance.changeDetails(for: fetchResult) else { return }
                
                self.fetchResult = changes.fetchResultAfterChanges
                self.hasChanges = true
                
                let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
                self.continuation?.yield(assets)
            }
        }
    }
}

extension PhotoLibraryClient: TestDependencyKey {
    public static var testValue: PhotoLibraryClient {
        PhotoLibraryClient()
    }
}

extension DependencyValues {
    public var photoLibraryClient: PhotoLibraryClient {
        get { self[PhotoLibraryClient.self] }
        set { self[PhotoLibraryClient.self] = newValue }
    }
}
