// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MusicWasmKit",
    platforms: [
        .iOS(.v15), .watchOS(.v7)
    ],
    products: [
        .singleTargetLibrary("MusicWasmKit"),
    ],
    dependencies: [
        .package(path: "/Users/thanhhaikhong/Desktop/AppExample/WasmHost"),
    ],
    targets: [
        .target(
            name: "MusicWasmKit",
            dependencies: [
                .product(name: "MusicWasm", package: "WasmHost"),
                .product(name: "AsyncWasm", package: "WasmHost"),
                .product(name: "AsyncWasmObjC", package: "WasmHost"),
                .product(name: "WasmObjCProtobuf", package: "WasmHost"),
            ]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
