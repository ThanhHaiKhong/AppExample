// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotosClient",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8), .visionOS(.v1)
    ],
    products: [
        .singleTargetLibrary("PhotosClient"),
        .singleTargetLibrary("PhotosClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/PHAssetExtensions"),
    ],
    targets: [
        .target(
            name: "PhotosClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
            ]
        ),
        .target(
            name: "PhotosClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
                "PhotosClient"
            ]
        ),
        .testTarget(
            name: "PhotosClientTests",
            dependencies: ["PhotosClient"]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
