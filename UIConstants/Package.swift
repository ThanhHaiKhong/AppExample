// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIConstants",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "UIConstants", targets: ["UIConstants"]),
    ],
    targets: [
        .target(
            name: "UIConstants"
        ),
    ]
)
