// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ImageKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ImageKit",
            targets: ["ImageKit"]
        ),
        .library(
            name: "ImageKitUI",
            targets: ["ImageKitUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke", exact: "12.8.0"),
    ],
    targets: [
        .target(
            name: "ImageKit",
            dependencies: []
        ),
        .target(
            name: "ImageKitUI",
            dependencies: [
                "ImageKit",
                .product(name: "NukeUI", package: "Nuke"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
