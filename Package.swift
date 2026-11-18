// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "InfomaniakFoundation",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "InfomaniakFoundation",
            targets: ["InfomaniakFoundation"]
        ),
        .library(
            name: "InfomaniakChunking",
            targets: ["InfomaniakChunking"]
        )
    ],
    targets: [
        .target(
            name: "InfomaniakFoundation"
        ),
        .target(
            name: "InfomaniakChunking"
        ),
        .testTarget(
            name: "InfomaniakFoundationTests",
            dependencies: ["InfomaniakFoundation"]
        ),
        .testTarget(
            name: "InfomaniakChunkingTests",
            dependencies: ["InfomaniakChunking"]
        )
    ]
)
