//
//  PHAssetExtensions.swift
//  Main
//
//  Created by Thanh Hai Khong on 2/10/24.
//

import Photos
import UniformTypeIdentifiers

extension PHAsset: @retroactive Identifiable {
    public var id: String { localIdentifier }
}

extension PHAsset {
    public enum AssetFetchError: Error {
        case resourceNotFound
        case fileWriteFailed(Error)
        case unknown
    }
}

extension PHAsset {
    
    public var fileName: String? {
        get async {
            var fileName: String? = self.value(forKey: "filename") as? String
            if fileName != nil {
                #if DEBUG
                print("PHASSET FILENAME: \(fileName!)")
                #endif
                return fileName
            }
            
            if let resource = PHAssetResource.assetResources(for: self).first {
                fileName = resource.originalFilename
            }
            print("PHASSET ORIGINAL_FILENAME: \(fileName!)")
            return fileName
        }
    }
    
    public var fileExtension: String? {
        get async {
            let fileExtension = await fileName?.split(separator: ".").last.map(String.init)
            return fileExtension
        }
    }
    
    public var formattedSize: String? {
        get async {
            if let size = await fileSize {
                ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
            }
            return nil
        }
    }
    
    public var fileSize: Int64? {
        get async {
            let resources = PHAssetResource.assetResources(for: self)
            var sizeOnDisk: Int64? = 0
            
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            }
            return sizeOnDisk
        }
    }
}

extension PHAsset {
    
    public func fileURL() async throws -> URL? {
        if mediaType == .image {
            return try await fetchAssetTemporaryURL(for: .fullSizePhoto)
        } else if mediaType == .video {
            return try await fetchAssetTemporaryURL(for: .fullSizeVideo)
        }
        return nil
    }
    
    public func getFilePath() async -> URL? {
        if self.mediaType == .image {
            return await getImagePath()
        } else if self.mediaType == .video {
            return await getAssetPath()
        } else {
            return nil
        }
    }
    
    private func fetchImageTemporaryURL() async throws -> URL {
        let fileURL = await fileTemporaryURL()

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions.default
            
            imageManager.requestImageDataAndOrientation(for: self, options: requestOptions) { data, _, _, error in
                if let error = error {
                    continuation.resume(throwing: error as! Error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: NSError(domain: "ImageError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Không có dữ liệu ảnh"]))
                    return
                }
                
                do {
                    try data.write(to: fileURL)
                    print("Đã lưu ảnh vào: \(fileURL.path)")
                    continuation.resume(returning: fileURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getImagePath() async -> URL? {
        let fileURL = await fileTemporaryURL()
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            return await withCheckedContinuation { continuation in
                PHImageManager.default().requestImageDataAndOrientation(for: self, options: PHImageRequestOptions.default) { (data, _, _, _) in
                    guard let data = data else {
                        print("Không thể lấy dữ liệu ảnh.")
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    do {
                        try data.write(to: fileURL)
                        print("Đã lưu ảnh vào: \(fileURL.path)")
                        continuation.resume(returning: fileURL)
                    } catch {
                        print("Lỗi khi lưu ảnh: \(error)")
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    private func getAssetPath() async -> URL? {
        let fileURL = await fileTemporaryURL()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            return await withCheckedContinuation { continuation in
                guard let resource = PHAssetResource.assetResources(for: self).first else {
                    print("Không thể lấy tài nguyên từ PHAsset.")
                    continuation.resume(returning: nil)
                    return
                }
                
                PHAssetResourceManager.default().writeData(for: resource, toFile: fileURL, options: PHAssetResourceRequestOptions.default) { error in
                    if let error = error {
                        print("Lỗi khi lưu video hoặc tài nguyên khác: \(error)")
                        continuation.resume(returning: nil)
                    } else {
                        print("Đã lưu video vào: \(fileURL.path)")
                        continuation.resume(returning: fileURL)
                    }
                }
            }
        }
    }
    
    private func fileTemporaryURL() async -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        if let fileName = await fileName {
            return temporaryDirectory.appendingPathComponent(fileName)
        }
        let fileURL = temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        return fileURL
    }

    private func fetchAssetTemporaryURL(for resourceType: PHAssetResourceType) async throws -> URL {
        let fileURL = await fileTemporaryURL()

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            let resources = PHAssetResource.assetResources(for: self)
            guard let resource = resources.first(where: { $0.type == resourceType }) else {
                continuation.resume(throwing: AssetFetchError.resourceNotFound)
                return
            }

            let options = PHAssetResourceRequestOptions.default
            PHAssetResourceManager.default().writeData(for: resource, toFile: fileURL, options: options) { error in
                if let error = error {
                    continuation.resume(throwing: AssetFetchError.fileWriteFailed(error))
                } else {
                    print("Đã lưu tài nguyên (\(resourceType)) vào: \(fileURL.path)")
                    continuation.resume(returning: fileURL)
                }
            }
        }
    }
}

extension PHAssetResourceRequestOptions {
    
    public static var `default`: PHAssetResourceRequestOptions {
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        return options
    }
}

extension PHImageRequestOptions {
    
    public static var `default`: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        return options
    }
}

extension PHFetchOptions {
    
    public static var all: PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return options
    }
    
    public static var favorite: PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "favorite == YES")
        return options
    }
    
    public static var recent: PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
    
    public static var burst: PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "burstIdentifier != nil")
        return options
    }
    
    public static var live: PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaSubtypes & %d != 0", PHAssetMediaSubtype.photoLive.rawValue)
        return options
    }
    
    public static var screenshot: PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaSubtypes & %d != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        return options
    }
}
