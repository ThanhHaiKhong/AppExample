// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataExtensions",
	platforms: [
		.iOS(.v15), .macOS(.v12)
	],
    products: [
        .library(
            name: "DataExtensions",
            targets: ["DataExtensions"]),
    ],
    targets: [
        .target(
            name: "DataExtensions"),

    ]
)
