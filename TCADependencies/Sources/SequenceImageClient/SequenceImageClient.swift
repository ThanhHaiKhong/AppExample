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
    public var processImages: @Sendable (_ imagePaths: [String], _ input: CompressionInput) async throws -> [SequenceCompressionResult]
    public var cleanUp: @Sendable () async throws -> Void
}

extension SequenceImageClient: DependencyKey {
    public static let liveValue: Self = .init(
        processImages: { imagePaths, input in
            return await SequenceImageProcessor.shared.processImages(imagePaths, input: input)
        },
        cleanUp: {
            return try await SequenceImageProcessor.shared.cleanUp()
        }
    )
}

extension SequenceImageClient: TestDependencyKey {
    public static var testValue: Self {
        Self()
    }
    
    public static var previewValue: Self {
        Self()
    }
}

extension DependencyValues {
    public var sequenceImageClient: SequenceImageClient {
        get { self[SequenceImageClient.self] }
        set { self[SequenceImageClient.self] = newValue }
    }
}
