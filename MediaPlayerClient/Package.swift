// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPlayerClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("MediaPlayerClient"),
        .singleTargetLibrary("MediaPlayerClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "MediaPlayerClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "MediaPlayerClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "MediaPlayerClient",
                "ZFPlayerObjC",
            ]
        ),
        .target(
            name: "ZFPlayerObjC",
            dependencies: [
                "IJKMediaFramework"
            ],
            path: "Sources/ZFPlayerObjC",
            publicHeadersPath: "."
        ),
        .binaryTarget(
            name: "IJKMediaFramework",
            path: "Frameworks/IJKMediaFramework.xcframework"
        )
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
