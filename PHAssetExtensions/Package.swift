// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PHAssetExtensions",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(name: "PHAssetExtensions", targets: ["PHAssetExtensions"]),
    ],
    targets: [
        .target(
            name: "PHAssetExtensions"
        ),
    ]
)
