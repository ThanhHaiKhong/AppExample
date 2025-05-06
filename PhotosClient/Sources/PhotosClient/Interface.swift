// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import Photos
import UIKit

@DependencyClient
public struct PhotosClient: Sendable {
    public var authorizationStatus: @Sendable () async -> PHAuthorizationStatus = { .notDetermined }
    public var fetchAssets: @Sendable (_ category: Category) async throws -> [PHAsset] = { _ in [] }
    public var observeChanges: @Sendable (_ category: Category) async throws -> AsyncStream<[PHAsset]> = { category in .finished }
    public var saveImages: @Sendable (_ paths: [String]) async throws -> Void = { _ in }
}
