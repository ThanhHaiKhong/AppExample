// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCAFeatureAction",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "TCAFeatureAction", targets: ["TCAFeatureAction"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "TCAFeatureAction",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
