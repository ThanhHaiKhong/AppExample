// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import ImageMagickClient
import ImageMagick

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
