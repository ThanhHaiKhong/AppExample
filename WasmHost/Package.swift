// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mffi_file_name = "mffi_asyncify_wasm_644da77e2c56.xcframework.zip"
let mffi_checksum = "644da77e2c56b6213c42216a850df43df85435807b36333b9ae93fd6b85f1ec9"

#if FFI_DEBUG
let ffiTargets: [PackageDescription.Target] = [
    .binaryTarget(name: "mffi",
                  path: "../../../target/ios/mffi_asyncify_wasm.zip"),
]
#else
let ffiTargets: [PackageDescription.Target] = [
    .binaryTarget(name: "mffi",
                  url: "https://wasm.sfo3.cdn.digitaloceanspaces.com/\(mffi_file_name)",
                  checksum: mffi_checksum),
]
#endif

let package = Package(
    name: "WasmHost",
    platforms: [
        .macOS(.v11), .iOS(.v14), .watchOS(.v7)
    ],
    products: [
        .library(name: "AsyncWasm", targets: ["AsyncWasm"]),
        .library(name: "MusicWasm", targets: ["MusicWasm"]),
        .library(name: "MusicWasmUI", type: .dynamic, targets: ["MusicWasmUI"]),
        .library(name: "AsyncWasmObjC", targets: ["AsyncWasmObjC"]),
        .library(name: "WasmObjCProtobuf", targets: ["WasmObjCProtobuf"]),
        .library(name: "WasmSwiftProtobuf", targets: ["WasmSwiftProtobuf"]),
    ],
    dependencies: [
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
        .testTarget(
            name: "AsyncWasmTests",
            dependencies: ["AsyncWasm"],
            resources: [
                .copy("Resources/music.wasm"),
            ]),
        .testTarget(
            name: "MusicWasmTests",
            dependencies: ["MusicWasm"],
            resources: [
                .copy("Resources/music.wasm"),
            ]),
        .testTarget(
            name: "MusicWasmObjCTests",
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
