//
//  PhotoFetcher.swift
//  Main
//
//  Created by Thanh Hai Khong on 2/10/24.
//

import ComposableArchitecture
import PHAssetExtensions
import Photos
import UIKit

@DependencyClient
public struct PhotoFetcher: Sendable {
    
    public enum FetchError: Error {
        case phAssetNotFound
    }
    
    public var thumbnailImage: @Sendable (_ localIdentifier: String, _ targetSize: CGSize) async -> AsyncThrowingStream<UIImage, Error> = { localIdentifier, targetSize in
        AsyncThrowingStream { continuation in
            Task(priority: .background) {
                let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                guard let asset = results.firstObject else {
                    continuation.finish(throwing: FetchError.phAssetNotFound)
                    return
                }
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .fast
                options.isNetworkAccessAllowed = true
                options.isSynchronous = false
                
                PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
                    guard let info = info, info[PHImageResultIsDegradedKey] as? Bool == false else {
                        return
                    }
                    
                    if let error = info[PHImageErrorKey] as? Error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    if let image = image {
                        continuation.yield(image)
                    }
                    continuation.finish()
                }
            }
        }
    }
    
    public var artworkImage: @Sendable (_ localIdentifier: String, _ targetSize: CGSize) async -> UIImage? = { localIdentifier, targetSize in
        await withCheckedContinuation { continuation in
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                continuation.resume(returning: nil)
                return
            }

            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    public var filePathURL: @Sendable (_ localIdentifier: String) async -> URL? = { localIdentifier in
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = results.firstObject else { return nil }
        return await asset.getFilePath()
    }
    
    public var exportedFileURls: @Sendable (_ localIdentifiers: [String]) async -> [URL] = { localIdentifiers in
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
        let assets: [PHAsset] = (0..<fetchResult.count).map { fetchResult.object(at: $0) }

        return await withTaskGroup(of: URL?.self) { group in
            for asset in assets {
                group.addTask {
                    /*
                    do {
                        return try await asset.fileURL()
                    } catch {
                        print("⚠️ Không thể lấy fileURL cho asset \(asset.localIdentifier): \(error)")
                        return nil
                    }
                    */
                    return await asset.getFilePath()
                }
            }

            var urls: [URL] = []
            for await url in group {
                if let url = url {
                    urls.append(url)
                }
            }
            return urls
        }
    }
    
    public var fileName: @Sendable (_ localIdentifier: String) async -> String? = { localIdentifier in
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = results.firstObject else { return nil }
        return await asset.fileName
    }
    
    public var fileSize: @Sendable (_ localIdentifier: String) async -> Int64? = { localIdentifier in
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = results.firstObject else { return nil }
        return await asset.fileSize
    }
}

extension PhotoFetcher: DependencyKey {
    public static var liveValue: PhotoFetcher {
        PhotoFetcher()
    }
}

extension PhotoFetcher: TestDependencyKey {
    public static var testValue: PhotoFetcher {
        PhotoFetcher()
    }
}

extension DependencyValues {
    public var photoFetcher: PhotoFetcher {
        get { self[PhotoFetcher.self] }
        set { self[PhotoFetcher.self] = newValue }
    }
}
