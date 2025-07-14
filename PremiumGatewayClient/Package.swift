// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PremiumGatewayClient",
	platforms: [
		.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)
	],
    products: [
        .singleTargetLibrary("PremiumGatewayClient"),
		.singleTargetLibrary("PremiumGatewayClientLive")
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
		.package(url: "https://github.com/ThanhHaiKhong/NetworkClient.git", branch: "master"),
	],
    targets: [
        .target(
            name: "PremiumGatewayClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "NetworkClient", package: "NetworkClient"),
			]
		),
		.target(
			name: "PremiumGatewayClientLive",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "NetworkClientLive", package: "NetworkClient"),
				"PremiumGatewayClient",
			]
		),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
