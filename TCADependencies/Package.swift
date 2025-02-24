// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCADependencies",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("TCADependencies"),
        .singleTargetLibrary("PhotoPermission"),
        .singleTargetLibrary("PhotoFetcher"),
        .singleTargetLibrary("PhotoLibraryClient"),
        .singleTargetLibrary("InAppPurchaseClient"),
        .singleTargetLibrary("ImageMagickClient"),
        .singleTargetLibrary("SequenceImageClient"),
        .singleTargetLibrary("Zipper"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
        .package(url: "https://github.com/marmelroy/Zip.git", branch: "master"),
        .package(path: "../PHAssetExtensions"),
        .package(path: "../ImageMagick"),
        .package(path: "../MobileAdsClient"),
    ],
    targets: [
        .target(
            name: "TCADependencies",
            dependencies: [
                "PhotoPermission",
                "PhotoFetcher",
                "PhotoLibraryClient",
                "RemoteConfigClient",
                "ImageMagickClient",
                "Zipper",
                "SequenceImageClient",
                "InAppPurchaseClient",
            ]
        ),
        .target(
            name: "ImageMagickClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
                "ImageMagick"
            ]
        ),
        .target(
            name: "SequenceImageClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
                "ImageMagick"
            ]
        ),
        .target(
            name: "PhotoPermission",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PhotoFetcher",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
            ]
        ),
        .target(
            name: "PhotoLibraryClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "PHAssetExtensions",
            ]
        ),
        .target(
            name: "InAppPurchaseClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "MobileAdsClientLive", package: "MobileAdsClient"),
            ]
        ),
        .target(
            name: "RemoteConfigClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ],
            resources: [
                .process("Resources/RemoteConfigDefaults.plist")
            ]
        ),
        .target(
            name: "Zipper",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Zip",
            ]
        )
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
