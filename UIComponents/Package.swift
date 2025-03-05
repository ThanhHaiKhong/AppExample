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
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/Pyroh/SmoothOperators.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://gitlab.com/Pyroh/CoreGeometry.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher", branch: "master"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/TCADependencies"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/UIConstants"),
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/UIModifiers"),
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
                .product(name: "RemoteConfigClient", package: "TCADependencies"),
                "Kingfisher",
                "UIConstants",
                "UIModifiers"
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
        )
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
