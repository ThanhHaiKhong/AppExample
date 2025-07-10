// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkCore",
	platforms: [
		.iOS(.v15)
	],
    products: [
        .singleTargetLibrary("NetworkCore")
    ],
	dependencies: [

	],
    targets: [
        .target(
            name: "NetworkCore",
		),
		.testTarget(
			name: "NetworkCoreTests",
			dependencies: [
				"NetworkCore"
			],
		),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
