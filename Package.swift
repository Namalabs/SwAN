// swift-tools-version: 6.2

import PackageDescription

// Before publishing: build SwAN.xcframework, zip it, upload to a GitHub Release,
// then set `url` and `checksum` (from `swift package compute-checksum SwAN.xcframework.zip`).

let package = Package(
    name: "SwAN",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "SwAN",
            targets: ["SwAN"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SwAN",
            url: "https://github.com/Namalabs/SwAN/releases/download/0.3.0/SwAN.xcframework.zip",
            checksum: "3ac919e38841ae2a7284e9e6a78fa9d9b5577b4abcada1ba82958d1ba01d7da1"
        ),
    ]
)
