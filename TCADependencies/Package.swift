// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCADependencies",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("InAppPurchaseClient"),
        .singleTargetLibrary("PhotoLibraryClient"),
        .singleTargetLibrary("RemoteConfigClient"),
        .singleTargetLibrary("TCADependencies"),
        .singleTargetLibrary("PhotoPermission"),
        .singleTargetLibrary("PhotoFetcher"),
        .singleTargetLibrary("Zipper"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
        .package(url: "https://github.com/marmelroy/Zip.git", branch: "master"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/PHAssetExtensions"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/ImageMagick"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/MobileAdsClient"),
    ],
    targets: [
        .target(
            name: "TCADependencies",
            dependencies: [
                "InAppPurchaseClient",
                "PhotoLibraryClient",
                "RemoteConfigClient",
                "PhotoPermission",
                "PhotoFetcher",
                "Zipper",
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
