// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PHAssetClient",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .singleTargetLibrary("PHAssetClient"),
        .singleTargetLibrary("PHAssetClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/PHAssetExtensions"),
    ],
    targets: [
        .target(
            name: "PHAssetClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PHAssetClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
                "PHAssetClient"
            ]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
