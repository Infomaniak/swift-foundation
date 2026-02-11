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
        )
    ],
    targets: [
        .target(
            name: "InfomaniakFoundation"
        ),
        .testTarget(
            name: "InfomaniakFoundationTests",
            dependencies: ["InfomaniakFoundation"]
        )
    ]
)
