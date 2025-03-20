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
import UIKit

@DependencyClient
public struct PhotoLibraryClient: Sendable {
    public var fetchAssets: @Sendable (_ category: Category) async throws -> [PHAsset]
    public var observeChanges: @Sendable () async throws -> AsyncStream<[PHAsset]>
    
    public enum Category: String, Identifiable, Equatable, CaseIterable, Sendable {
        case all = "All Photos"
        case favorite = "Favorites"
        case recent = "Recents"
        case burst = "Burst Photos"
        case live = "Live Photos"
        case screenShot = "Screenshots"
        
        public var id: String { rawValue }
        
        public var systemName: String {
            switch self {
            case .all: return "photo.stack.fill"
            case .favorite: return "star.fill"
            case .recent: return "clock.fill"
            case .burst: return "square.stack.3d.forward.dottedline"
            case .live: return "livephoto"
            case .screenShot: return "camera.viewfinder"
            }
        }
        
        public var activeColor: UIColor {
            switch self {
            case .all: return .systemIndigo
            case .favorite: return .systemYellow
            case .recent: return .systemGreen
            case .burst: return .systemRed
            case .live: return .systemBlue
            case .screenShot: return .systemOrange
            }
        }
        
        public var fetchOptions: PHFetchOptions {
            switch self {
            case .all: return .all
            case .favorite: return .favorite
            case .recent: return .recent
            case .burst: return .burst
            case .live: return .live
            case .screenShot: return .screenshot
            }
        }
    }
}

extension PhotoLibraryClient: DependencyKey {
    public static var liveValue: PhotoLibraryClient {
        let actor = PhotoLibraryActor()
        return PhotoLibraryClient(
            fetchAssets: { category in
                return try await actor.fetchAssets(category: category)
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
        
        public func fetchAssets(category: Category = .all) async throws -> [PHAsset] {
            try await observer.fetchAssets(category: category)
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
            
            public func fetchAssets(category: Category) async throws -> [PHAsset] {
                return try await withCheckedThrowingContinuation { continuation in
                    fetchResult = PHAsset.fetchAssets(with: .image, options: category.fetchOptions)
                    
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
