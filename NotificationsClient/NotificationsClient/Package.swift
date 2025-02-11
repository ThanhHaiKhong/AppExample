// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationsClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("NotificationsClient"),
        .singleTargetLibrary("NotificationsClientLive"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "NotificationsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .target(
            name: "NotificationsClientLive",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

