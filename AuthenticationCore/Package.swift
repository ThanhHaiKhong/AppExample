// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthenticationCore",
	platforms: [
		.iOS(.v15), .macOS(.v10_15)
	],
    products: [
        .singleTargetLibrary("AuthenticationCore"),
    ],
	dependencies: [
		.package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.15.0"),
	],
    targets: [
        .target(
            name: "AuthenticationCore",
			dependencies: [
				.product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
				.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
			],
		),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
