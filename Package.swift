// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "NavigationCompat",
    platforms: [
        .iOS(.v13),
        .watchOS(.v7),
        .macOS(.v12),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "NavigationCompat",
            targets: ["NavigationCompat"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:shaps80/SwiftUIBackports.git", exact: "1.6.2"),
    ],
    targets: [
        .target(
            name: "NavigationCompat",
            dependencies: [
                "SwiftUIBackports",
            ]
        ),
        .testTarget(
            name: "NavigationCompatTests",
            dependencies: ["NavigationCompat"]
        ),
    ]
)
