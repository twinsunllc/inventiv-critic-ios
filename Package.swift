// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Critic",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Critic",
            targets: ["Critic"]
        )
    ],
    targets: [
        .target(
            name: "Critic"
        ),
        .testTarget(
            name: "CriticTests",
            dependencies: ["Critic"]
        )
    ]
)
