// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkClient",
	platforms: [
		.iOS(.v15),
	],
    products: [
        .singleTargetLibrary("NetworkClient"),
		.singleTargetLibrary("NetworkClientLive"),
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
	],
    targets: [
        .target(
			name: "NetworkClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "NetworkClientLive",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"NetworkClient",
			]
		),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: [
				"NetworkClient",
				"NetworkClientLive"
			]
        ),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
