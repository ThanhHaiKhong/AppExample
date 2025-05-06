// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIExtensions",
	platforms: [
		.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8),
	],
    products: [
		.singleTargetLibrary(name: "UIExtensions"),
        .singleTargetLibrary(name: "UIFontExtensions"),
		.singleTargetLibrary(name: "UIImageExtensions"),
    ],
	dependencies: [
		
	],
    targets: [
		.target(
			name: "UIExtensions",
			dependencies: [
				"UIFontExtensions",
				"UIImageExtensions",
			]
		),
        .target(
            name: "UIFontExtensions"
		),
		.target(
			name: "UIImageExtensions"
		),
    ]
)

extension Product {
	static func singleTargetLibrary(name: String) -> Product {
		.library(name: name, targets: [name])
	}
}
