// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContextMenuBuilder",
	platforms: [
		.iOS(.v15)
	],
    products: [
		.singleTargetLibrary(name: "ContextMenuBuilder"),
    ],
	dependencies: [
		
	],
    targets: [
        .target(
            name: "ContextMenuBuilder",
			dependencies: [
				
			],
		),
    ]
)

extension Product {
	static func singleTargetLibrary(name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
