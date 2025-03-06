// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import ImageMagick

@DependencyClient
public struct ImageMagickClient: Sendable {
    public var getMetadata: @Sendable (_ imagePath: String) async throws -> Metadata
    public var getAvailableImageFormats: @Sendable () async throws -> [String]
    public var getCompressedPath: @Sendable () async throws -> String
    public var processingImage: @Sendable (_ imagePath: String, _ input: CompressionInput) async throws -> CompressionResult
    public var cleanUp: @Sendable () async throws -> Void
}
