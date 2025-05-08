// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MusicWasmClient",
	platforms: [
		.iOS(.v15), .macOS(.v11), .watchOS(.v7)
	],
    products: [
		.singleTargetLibrary("MusicWasmClient"),
		.singleTargetLibrary("MusicWasmClientLive")
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
		.package(url: "https://github.com/ThanhHaiKhong/WasmHost.git", branch: "master")
	],
    targets: [
        .target(
            name: "MusicWasmClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "WasmSwiftProtobuf", package: "WasmHost"),
				.product(name: "MusicWasm", package: "WasmHost"),
			]
		),
		.target(
			name: "MusicWasmClientLive",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				.product(name: "AsyncWasm", package: "WasmHost"),
				.product(name: "MusicWasm", package: "WasmHost"),
				.product(name: "TaskWasm", package: "WasmHost"),
				.product(name: "WasmSwiftProtobuf", package: "WasmHost"),
				"MusicWasmClient",
			]
		),
    ]
)

extension Product {
	static func singleTargetLibrary(_ name: String, type: Library.LibraryType? = nil) -> Product {
		return .library(name: name, type: type, targets: [name])
	}
}
