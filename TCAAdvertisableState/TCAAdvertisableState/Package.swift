// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCAAdvertisableState",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("TCAAdvertisableState")
    ],
    dependencies: [
        .package(path: "../MobileAdsClient"),
        .package(path: "../TCAInitializableReducer"),
    ],
    targets: [
        .target(
            name: "TCAAdvertisableState",
            dependencies: [
                .product(name: "MobileAdsClientUI", package: "MobileAdsClient"),
                "TCAInitializableReducer"
            ]
        ),

    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
