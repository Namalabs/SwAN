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
            url: "https://github.com/Namalabs/SwAN/releases/download/0.3.1/SwAN.xcframework.zip",
            checksum: "b94c1d9790ead4eb4797a80799efcf8569139aa7e62bd2020e0baf56b28541a1"
        ),
    ]
)
