//
//  Live.swift
//  PHAssetClient
//
//  Created by Thanh Hai Khong on 10/4/25.
//

import ComposableArchitecture
import PHAssetExtensions
import PHAssetClient
import Photos

extension PHAssetClient: DependencyKey {
    public static var liveValue: PHAssetClient {
        return .init(
            thumbnailImage: { localIdentifier, size in
                try await withCheckedThrowingContinuation { continuation in
                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                    guard let asset = fetchResult.firstObject else {
                        continuation.resume(throwing: PHAssetClient.FetchError.phAssetNotFound)
                        return
                    }
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.isNetworkAccessAllowed = true
                    
                    PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
                        if let image {
                            continuation.resume(returning: image)
                        }
                    }
                }
            },
            fileURLs: { localIdentifiers in
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
                let assets: [PHAsset] = (0..<fetchResult.count).map { fetchResult.object(at: $0) }
                
                return await withTaskGroup(of: URL?.self) { group in
                    for asset in assets {
                        group.addTask {
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
            },
            fileName: { localIdentifier in
                let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                guard let asset = results.firstObject, let fileName = await asset.fileName else {
                    throw PHAssetClient.FetchError.phAssetNotFound
                }
                
                return fileName
            },
            fileSize: { localIdentifier in
                let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                guard let asset = results.firstObject, let fileSize = await asset.fileSize else {
                    throw PHAssetClient.FetchError.phAssetNotFound
                }
                
                return fileSize
            }
        )
    }
}
