// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebugKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .singleTargetLibrary("Logging"),
        .singleTargetLibrary("Performance"),
        .singleTargetLibrary("UIDebugging"),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "Logging",
            dependencies: [
                
            ]
        ),
        .target(
            name: "Performance",
            dependencies: [
                
            ]
        ),
        .target(
            name: "UIDebugging",
            dependencies: [
                
            ]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
