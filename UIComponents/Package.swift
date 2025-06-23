// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("UIComponents"),
        .singleTargetLibrary("FlipView"),
        .singleTargetLibrary("LoadingSpinner"),
        .singleTargetLibrary("SlidingRuler"),
        .singleTargetLibrary("BlurView"),
        .singleTargetLibrary("EditorChoiceView"),
        .singleTargetLibrary("SettingsView"),
        .singleTargetLibrary("ModalTransition"),
        .singleTargetLibrary("WaveformView"),
		.singleTargetLibrary("AutoHidingStackView"),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/Pyroh/SmoothOperators.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://gitlab.com/Pyroh/CoreGeometry.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher", branch: "master"),
		.package(url: "https://github.com/ThanhHaiKhong/RemoteConfigClient.git", branch: "master"),
		.package(url: "https://github.com/ThanhHaiKhong/UIModifiers.git", branch: "master"),
		.package(url: "https://github.com/ThanhHaiKhong/UIConstants.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                "SlidingRuler",
                "FlipView",
                "LoadingSpinner",
                "BlurView",
                "EditorChoiceView",
                "SettingsView",
                "ModalTransition",
				"AutoHidingStackView",
				"PaddedLabel"
            ]
        ),
        .target(
            name: "FlipView"
        ),
        .target(
            name: "SlidingRuler",
            dependencies: [
                "SmoothOperators",
                "CoreGeometry",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "LoadingSpinner"
        ),
        .target(
            name: "BlurView"
        ),
        .target(
            name: "EditorChoiceView",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Kingfisher",
                "UIConstants",
                "UIModifiers",
                "RemoteConfigClient"
            ]
        ),
        .target(
            name: "SettingsView",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UIConstants",
                "UIModifiers",
                "BlurView"
            ]
        ),
        .target(
            name: "ModalTransition",
        ),
        .target(
            name: "WaveformView",
        ),
		.target(
			name: "AutoHidingStackView",
		),
		.target(
			name: "PaddedLabel",
		),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
