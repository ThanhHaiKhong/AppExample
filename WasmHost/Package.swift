// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WasmHost",
    platforms: [
        .macOS(.v11), .iOS(.v14),
    ],
    products: [
        .library(name: "AsyncWasm", targets: ["AsyncWasm"]),
        .library(name: "AsyncWasmObjC", targets: ["AsyncWasmObjC"]),
        .library(name: "MusicWasm", targets: ["MusicWasm"]),
        .library(name: "MusicWasmUI", targets: ["MusicWasmUI"]),
        .library(name: "MusicWasmProtobuf", targets: ["MusicWasmProtobuf"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.22.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AsyncWasm",
            dependencies: [
                .product(name: "WasmKit", package: "WasmKit"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ]
        ),
        .target(
            name: "MusicWasm",
            dependencies: [
                "AsyncWasm",
            ],
            resources: [
                .copy("Resources/details.dat"),
                .copy("Resources/search.dat"),
            ]
        ),
        .target(
            name: "MusicWasmUI",
            dependencies: [
                "MusicWasm"
            ]
        ),
        // https://github.com/protocolbuffers/protobuf/blob/main/Protobuf.podspec
        .target(
            name: "Protobuf",
            dependencies: [
            ],
            exclude: [
                "GPBUnknownField+Additions.swift",
                "GPBUnknownFields+Additions.swift",
                "GPBProtocolBuffers.m"
            ],
            publicHeadersPath: "",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ]
        ),
        .target(
            name: "AsyncWasmObjC",
            dependencies: [
                "Protobuf",
                "AsyncWasm",
            ],
            publicHeadersPath: "include"
        ),
        .target(
            name: "MusicWasmProtobuf",
            dependencies: [
                "Protobuf",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ]
        ),
        .testTarget(name: "AsyncWasmTests",
                    dependencies: ["AsyncWasm"],
                    resources: [
                        .copy("Resources/music.wasm"),
                    ]),
        .testTarget(name: "MusicWasmTests",
                    dependencies: ["MusicWasm"],
                    resources: [
                        .copy("Resources/music.wasm"),
                    ]),
        .testTarget(name: "MusicWasmObjCTests",
                    dependencies: [
                        "MusicWasmProtobuf",
                        "AsyncWasmObjC",
                        "MusicWasm"
                    ],
                    resources: [
                        .copy("Resources/music.wasm"),
                    ])
    ]
)
