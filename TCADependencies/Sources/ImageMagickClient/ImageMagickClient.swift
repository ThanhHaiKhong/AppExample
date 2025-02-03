//
//  ImageMagickClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 27/12/24.
//

import ComposableArchitecture
import ImageMagick
import UIKit

@DependencyClient
public struct ImageMagickClient: Sendable {
    public var getMetadata: @Sendable (_ imagePath: String) async throws -> Metadata
    public var getAvailableImageFormats: @Sendable () async throws -> [String]
    public var getCompressedPath: @Sendable () async throws -> String
    public var processingImage: @Sendable (_ imagePath: String, _ input: CompressionInput) async throws -> CompressionResult
    public var cleanUp: @Sendable () async throws -> Void
}

extension ImageMagickClient: DependencyKey {
    public static let liveValue: ImageMagickClient = .init(
        getMetadata: { imagePath in
            return try await ImageProcessor.shared.getMetadata(from: imagePath)
        },
        getAvailableImageFormats: { 
            return try await ImageProcessor.shared.listAvailableImageFormats()
        },
        getCompressedPath: {
            return try await ImageProcessor.shared.getCompressedPath()
        },
        processingImage: { imagePath, input in
            return try await ImageProcessor.shared.processingImage(imagePath, input: input)
        },
        cleanUp: {
            return try await ImageProcessor.shared.cleanUp()
        }
    )
}

extension ImageMagickClient: TestDependencyKey {
    public static var testValue: ImageMagickClient {
        Self()
    }
}

extension DependencyValues {
    public var imageMagickClient: ImageMagickClient {
        get { self[ImageMagickClient.self] }
        set { self[ImageMagickClient.self] = newValue }
    }
}
