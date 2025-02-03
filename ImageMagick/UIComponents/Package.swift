// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "FlipView", targets: ["FlipView"]),
        .library(name: "SlidingRuler", targets: ["SlidingRuler"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Pyroh/SmoothOperators.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://gitlab.com/Pyroh/CoreGeometry.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                "SlidingRuler",
                "FlipView"
            ]
        ),
        .target(
            name: "FlipView"
        ),
        .target(
            name: "SlidingRuler",
            dependencies: [
                "SmoothOperators",
                "CoreGeometry",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
