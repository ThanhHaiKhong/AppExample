//
//  PhotoLibraryActor.swift
//  PhotosClient
//
//  Created by Thanh Hai Khong on 1/4/25.
//

import PHAssetExtensions
import PhotosClient
import Photos

public final actor PhotoLibraryActor {
        
    private var observer: PhotoLibraryObserver?
    
    public func authorizationStatus() async -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
        
    public func fetchAssets(category: PhotosClient.Category) async throws -> [PHAsset] {
        return try await withCheckedThrowingContinuation { continuation in
            let fetchResult = PHAsset.fetchAssets(with: category.fetchOptions)
            let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
            continuation.resume(returning: assets)
        }
    }
        
    public func observeChanges(category: PhotosClient.Category, options: PHFetchOptions? = nil) -> AsyncStream<[PHAsset]> {
        ensureObserverInitialized()
        return observer!.observeChanges(category: category, options: options)
    }
    
    private func ensureObserverInitialized() {
        if observer == nil {
            observer = PhotoLibraryObserver()
        }
    }
    
    public func saveImages(paths: [String]) async throws {
        let status = await authorizationStatus()
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.permissionDenied
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                for imagePath in paths {
                    guard let fileURL = URL(string: imagePath), FileManager.default.fileExists(atPath: fileURL.path) else {
                        continue // Or throw an error for invalid paths
                    }
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, fileURL: fileURL, options: nil)
                }
            }) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: PhotoLibraryError.unknown)
                }
            }
        }
    }
        
    private final class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver, @unchecked Sendable {
        private var streams: [UUID: (category: PhotosClient.Category, options: PHFetchOptions?, continuation: AsyncStream<[PHAsset]>.Continuation)] = [:]
        
        override init() {
            super.init()
            PHPhotoLibrary.shared().register(self)
        }
        
        deinit {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
            streams.values.forEach { $0.continuation.finish() }
        }
        
        public func observeChanges(category: PhotosClient.Category, options: PHFetchOptions?) -> AsyncStream<[PHAsset]> {
            AsyncStream { continuation in
                let id = UUID()
                streams[id] = (category, options, continuation)
                
                let fetchOptions = options ?? category.fetchOptions
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
                continuation.yield(assets)
                
                continuation.onTermination = { [weak self] _ in
                    self?.removeStream(id: id)
                }
            }
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            for (_, (category, options, continuation)) in streams {
                let fetchOptions = options ?? category.fetchOptions
                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                let assets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
                continuation.yield(assets)
            }
        }
        
        private func removeStream(id: UUID) {
            streams.removeValue(forKey: id)
        }
    }
}

public enum PhotoLibraryError: Error, Sendable {
    case permissionDenied
    case unknown
}
