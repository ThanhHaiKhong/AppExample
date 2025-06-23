// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIModifiers",
    platforms: [
        .iOS(.v13)
    ],
    products: [
		.singleTargetLibrary("UIModifiers"),
    ],
    targets: [
        .target(
            name: "UIModifiers"
		),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
