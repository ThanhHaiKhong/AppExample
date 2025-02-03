//
//  ImageMagickClient.swift
//  TCADependencies
//
//  Created by Thanh Hai Khong on 17/1/25.
//

import ComposableArchitecture
import ImageMagick
import UIKit

@DependencyClient
public struct SequenceImageClient: Sendable {
    public var processImagesWithProgress: @Sendable (_ imagePaths: [String], _ input: CompressionInput) async throws -> AsyncStream<SequenceProgress>
    public var processImages: @Sendable (_ imagePaths: [String], _ input: CompressionInput) async throws -> AsyncStream<SequenceProgress>
    public var processImagesWithoutProgress: @Sendable (_ imagePaths: [String], _ input: CompressionInput) async throws -> [SequenceCompressionResult]
    public var cleanUp: @Sendable () async throws -> Void
}

extension SequenceImageClient: DependencyKey {
    public static let liveValue: SequenceImageClient = .init(
        processImagesWithProgress: { imagePaths, input in
            return AsyncStream { continuation in
                Task {
                    let results = await SequenceImageProcessor.shared.processImages(imagePaths, input: input) { progress in
                        continuation.yield(.inProcessing(progress))
                    }
                    continuation.yield(.finished(results))
                }
            }
        },
        processImages: { imagePaths, input in
            return try await SequenceImageProcessor.shared.processImages(imagePaths, input: input)
        },
        processImagesWithoutProgress: { imagePaths, input in
            return await SequenceImageProcessor.shared.processImages(imagePaths, input: input)
        },
        cleanUp: {
            return try await SequenceImageProcessor.shared.cleanUp()
        }
    )
}

extension SequenceImageClient: TestDependencyKey {
    public static var testValue: SequenceImageClient {
        Self()
    }
}

extension DependencyValues {
    public var sequenceImageClient: SequenceImageClient {
        get { self[SequenceImageClient.self] }
        set { self[SequenceImageClient.self] = newValue }
    }
}
