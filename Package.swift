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
            checksum: "bcfa9679ade12a6eab4ba7838fed3cff8077434df3637a8c43dad25882409a3c"
        ),
    ]
)
