// The Swift Programming Language
// https://docs.swift.org/swift-book
//

import ComposableArchitecture
import Photos
import UIKit

@DependencyClient
public struct PHAssetClient: Sendable {
    public var thumbnailImage: @Sendable (_ localIdentifier: String, _ targetSize: CGSize) async throws -> UIImage = { _, _  in UIImage(systemName: "photo")! }
    public var fileURLs: @Sendable (_ localIdentifiers: [String]) async -> [URL] = { _ in [] }
    public var fileName: @Sendable (_ localIdentifier: String) async throws -> String = { _ in "File Name" }
    public var fileSize: @Sendable (_ localIdentifier: String) async throws -> Int64 = { _ in 0 }
}
