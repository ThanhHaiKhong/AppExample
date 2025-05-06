// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimerClient",
	platforms: [
		.iOS(.v15)
	],
    products: [
		.singleTargetLibrary("TimerClient"),
		.singleTargetLibrary("TimerClientLive"),
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
	],
    targets: [
        .target(
            name: "TimerClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		),
		.target(
			name: "TimerClientLive",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"TimerClient",
			]
		),
    ]
)

extension Product {
	public static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
