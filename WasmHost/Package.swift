// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if FFI_DEBUG
let ffiTargets: [PackageDescription.Target] = [
    .binaryTarget(name: "mffi",
                  path: "../../../target/ios/mffi_asyncify_wasm.xcframework.zip"),
]
#else
let ffiTargets: [PackageDescription.Target] = [
    .binaryTarget(name: "mffi",
                  url: "https://wasm.sfo3.cdn.digitaloceanspaces.com/l7mobile.xcframework.zip",
                  checksum: "ff288901ee0afb91904703754474ba367c5a07ef0d1f9f30e62816da5e6200f4"),
]
#endif

let package = Package(
    name: "WasmHost",
    platforms: [
        .macOS(.v11), .iOS(.v14),
    ],
    products: [
        .library(name: "AsyncWasm", targets: ["AsyncWasm"]),
        .library(name: "AsyncWasmKit", targets: ["AsyncWasmKit"]),
        .library(name: "AsyncWasmObjC", targets: ["AsyncWasmObjC"]),
        .library(name: "MobileFFI", targets: ["MobileFFI"]),
        .library(name: "WasmObjCProtobuf", targets: ["WasmObjCProtobuf"]),
        .library(name: "WasmSwiftProtobuf", targets: ["WasmSwiftProtobuf"]),
        .library(name: "MusicWasm", targets: ["MusicWasm"]),
        .library(name: "MusicWasmUI", type: .dynamic, targets: ["MusicWasmUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.22.0"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0")
    ],
    targets: ffiTargets + [
        .target(
            name: "WasmSwiftProtobuf",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ]
        ),
        .target(
            name: "AsyncWasmKit",
            dependencies: [
                .product(name: "WasmKit", package: "WasmKit"),
                "WasmSwiftProtobuf",
            ]
        ),
        .target(
            name: "AsyncWasm",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                "WasmSwiftProtobuf",
                "MobileFFI"
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
            name: "WasmObjCProtobuf",
            dependencies: [
                "Protobuf",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ]
        ),
        .target(
            name: "MobileFFI",
            dependencies: [
                "mffi",
                "WasmSwiftProtobuf"
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
                        "WasmObjCProtobuf",
                        "AsyncWasmObjC",
                        "MusicWasm"
                    ],
                    resources: [
                        .copy("Resources/music.wasm"),
                    ])
    ]
)
