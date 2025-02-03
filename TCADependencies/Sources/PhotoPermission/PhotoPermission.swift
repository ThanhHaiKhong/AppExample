//
//  PhotoPermission.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 2/12/24.
//

import ComposableArchitecture
import Photos
import UIKit

@DependencyClient
public struct PhotoPermission: Sendable {
    
    public var authorizationStatus: @Sendable () async -> PHAuthorizationStatus = {
        await withCheckedContinuation { continuation in
            let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

            if currentStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    continuation.resume(returning: newStatus)
                }
            } else {
                continuation.resume(returning: currentStatus)
            }
        }
    }
    
    public func saveImagesToPhotoLibrary(imagePaths: [String]) async throws {
        let status = await authorizationStatus()
        switch status {
        case .authorized:
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                PHPhotoLibrary.shared().performChanges({
                    for imagePath in imagePaths {
                        let fileURL = URL(fileURLWithPath: imagePath)
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .photo, fileURL: fileURL, options: nil)
                    }
                }) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if success {
                        continuation.resume()
                    }
                }
            }
            
        default:
            throw NSError(domain: "PhotoLibraryAccess", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
        }
    }
}

extension PhotoPermission: DependencyKey {
    public static var liveValue: PhotoPermission {
        PhotoPermission()
    }
}

extension PhotoPermission: TestDependencyKey {
    public static var testValue: PhotoPermission {
        PhotoPermission()
    }
}

extension DependencyValues {
    public var photoPermission: PhotoPermission {
        get { self[PhotoPermission.self] }
        set { self[PhotoPermission.self] = newValue }
    }
}
