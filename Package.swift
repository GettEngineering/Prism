// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "PrismCore",
    products: [
        .executable(name: "Prism",
                    targets: ["Prism"]),
        .library(
            name: "PrismCore",
            targets: ["PrismCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Prism",
            dependencies: ["PrismCore"],
            path: "Run"
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
