// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "PrismCore",
    products: [
        .executable(name: "prism",
                    targets: ["prism"]),
        .library(
            name: "PrismCore",
            targets: ["PrismCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devedbox/Commander.git", from: "0.5.6")
    ],
    targets: [
        .target(
            name: "prism",
            dependencies: ["PrismCore", "Commander"],
            path: "CLI"
        ),
        .target(
            name: "PrismCore",
            dependencies: [],
            path: "Sources"),
//        .testTarget(
//            name: "PrismTests",
//            dependencies: ["Prism"],
//            path: "Tests"),
    ]
)
