// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIKitPreviews",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "UIKitPreviews", targets: ["UIKitPreviews"])
    ],
    targets: [
        .target(
            name: "UIKitPreviews",
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
