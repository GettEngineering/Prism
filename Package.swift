// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v4)
    ],
    products: [
        .executable(name: "prism",
                    targets: ["prism"]),
        .library(
            name: "PrismCore",
            targets: ["PrismCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devedbox/Commander.git", from: "0.5.6"),
        .package(url: "https://github.com/Quick/Quick", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "8.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.5.0"),
        .package(url: "https://github.com/BuzzFeed/MockDuck", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "prism",
            dependencies: ["PrismCore", "Commander"],
            path: "CLI"
        ),
        .target(
            name: "PrismCore",
            dependencies: ["Yams"],
            path: "Sources"),
       .testTarget(
           name: "PrismTests",
           dependencies: ["prism", "Quick", "Nimble", "MockDuck", "Yams", "SnapshotTesting"],
           path: "Tests")
    ]
)
