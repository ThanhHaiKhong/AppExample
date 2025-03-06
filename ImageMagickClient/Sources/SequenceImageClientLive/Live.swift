// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import SequenceImageClient
import ImageMagick

extension SequenceImageClient: DependencyKey {
    public static let liveValue: Self = .init(
        processImages: { imagePaths, input in
            return await SequenceImageProcessor.shared.processImages(imagePaths, input: input)
        },
        cleanUp: {
            return try await SequenceImageProcessor.shared.cleanUp()
        },
        cancel: {
            return try await SequenceImageProcessor.shared.cancel()
        }
    )
}

