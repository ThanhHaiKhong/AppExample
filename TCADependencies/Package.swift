// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCADependencies",
    platforms: [
        .iOS(.v14)
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
        .singleTargetLibrary("AppTrackingClient"),
        .singleTargetLibrary("MobileAdsClient"),
        .singleTargetLibrary("MobilePlatformClient"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
        .package(url: "https://github.com/marmelroy/Zip.git", branch: "master"),
        .package(path: "../PHAssetExtensions"),
        .package(path: "../ImageMagick"),
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
                "MobileAdsClient",
                "AppTrackingClient",
                "MobilePlatformClient",
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
        ),
        .target(
            name: "MobileAdsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .target(
            name: "AppTrackingClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "MobilePlatformClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "MobileAdsClient",
                "InAppPurchaseClient",
                "AppTrackingClient",
            ]
        )
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
