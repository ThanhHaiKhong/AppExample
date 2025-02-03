// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageMagick",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "ImageMagick", targets: ["ImageMagick"]),
    ],
    targets: [
        .target(
            name: "ImageMagick",
            dependencies: ["ImageMagickObjC"]
        ),
        .target(
            name: "ImageMagickObjC",
            dependencies: [],
            path: "./Sources/ImageMagickObjC",
            cSettings: [
                .headerSearchPath("../Sources/ImageMagickObjC/include"),
                .define("HAVE_MAGICKWAND", to: "1"),
                .define("MAGICKCORE_HDRI_ENABLE", to: "1"),
                .define("MAGICKCORE_QUANTUM_DEPTH", to: "16")
            ],
            linkerSettings: [
                .linkedLibrary("MagickWand"),
                .linkedLibrary("MagickCore"),
                .linkedLibrary("bz2"),
                .linkedLibrary("xml2"),
                .linkedLibrary("jpeg"),
                .linkedLibrary("png"),
                .linkedLibrary("tiff"),
                .unsafeFlags([
                    "-L", "../Sources/ImageMagickObjC/lib"
                ])
            ]
        )
    ]
)
