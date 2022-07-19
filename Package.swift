// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "NavigationCompat",
    platforms: [
        .iOS(.v13),
        .watchOS(.v7),
        .macOS(.v11),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "NavigationCompat",
            targets: ["NavigationCompat"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NavigationCompat",
            dependencies: []
        ),
        .testTarget(
            name: "NavigationCompatTests",
            dependencies: ["NavigationCompat"]
        ),
    ]
)
