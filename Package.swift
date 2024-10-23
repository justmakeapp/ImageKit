// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ImageKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ImageKit",
            targets: ["ImageKit"]
        ),
    ],
    targets: [
        .target(
            name: "ImageKit",
            dependencies: []
        ),
    ],
    swiftLanguageModes: [.v6]
)
