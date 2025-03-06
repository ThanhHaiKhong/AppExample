// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageMagickClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("ImageMagickClient"),
        .singleTargetLibrary("ImageMagickClientLive"),
        .singleTargetLibrary("SequenceImageClient"),
        .singleTargetLibrary("SequenceImageClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/ImageMagick"),
    ],
    targets: [
        .target(
            name: "ImageMagickClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImageMagick"
            ]
        ),
        .target(
            name: "ImageMagickClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImageMagick",
                "ImageMagickClient"
            ]
        ),
        .target(
            name: "SequenceImageClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImageMagick"
            ]
        ),
        .target(
            name: "SequenceImageClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "ImageMagick",
                "SequenceImageClient"
            ]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
