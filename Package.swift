// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(
            name: "prism",
            targets: ["prism"]
        ),
        .library(
            name: "PrismCore",
            targets: ["PrismCore"]
        ),
        .library(
            name: "ZeplinSwift",
            targets: ["ZeplinSwift"]
        ),
        .library(
            name: "FigmaSwift",
            targets: ["FigmaSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/Quick/Quick", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.5.0"),
        .package(url: "https://github.com/BuzzFeed/MockDuck", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "prism",
            dependencies: [
                "PrismCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        .target(
            name: "PrismCore",
            dependencies: ["ZeplinSwift", "FigmaSwift", "Yams"],
            path: "Sources/PrismCore"),
        .target(
            name: "ZeplinSwift",
            dependencies: ["ProviderCore"],
            path: "Sources/Providers/ZeplinAPI"),
        .target(
            name: "FigmaSwift",
            dependencies: ["ProviderCore"],
            path: "Sources/Providers/FigmaAPI"),
        .target(
            name: "ProviderCore",
            dependencies: [],
            path: "Sources/Providers/ProviderCore")
    //    .testTarget(
    //        name: "PrismTests",
    //        dependencies: ["prism", "Quick", "Nimble", "MockDuck", "Yams", "SnapshotTesting"],
    //        path: "Tests")
    ]
)
