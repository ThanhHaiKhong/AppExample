// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIKitPreviews",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("UIKitPreviews"),
    ],
    targets: [
        .target(
            name: "UIKitPreviews"
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
