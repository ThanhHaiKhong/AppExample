// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseAuthClient",
	platforms: [
		.iOS(.v15),
	],
    products: [
        .singleTargetLibrary("FirebaseAuthClient"),
		.singleTargetLibrary("FirebaseAuthClientLive"),
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
		.package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.15.0"),
	],
    targets: [
        .target(
			name: "FirebaseAuthClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
				.product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
			],
		),
		.target(
			name: "FirebaseAuthClientLive",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
				.product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
				"FirebaseAuthClient",
			],
		),
        .testTarget(
            name: "FirebaseAuthClientTests",
            dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
				.product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
				"FirebaseAuthClient"
			]
        ),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		return .library(name: name, targets: [name])
	}
}
