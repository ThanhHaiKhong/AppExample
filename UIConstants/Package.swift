// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIConstants",
    platforms: [
        .iOS(.v13)
    ],
    products: [
		.singleTargetLibrary("UIConstants"),
    ],
    targets: [
        .target(
            name: "UIConstants"
        ),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
