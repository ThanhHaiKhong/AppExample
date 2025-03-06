// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import ImageMagick

@DependencyClient
public struct SequenceImageClient: Sendable {
    public var processImages: @Sendable (_ imagePaths: [String], _ input: CompressionInput) async throws -> [SequenceCompressionResult]
    public var cleanUp: @Sendable () async throws -> Void
    public var cancel: @Sendable () async throws -> Void
}
