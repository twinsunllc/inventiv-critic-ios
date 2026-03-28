// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "CriticExample",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "CriticExample",
            dependencies: [
                .product(name: "Critic", package: "inventiv-critic-ios")
            ],
            path: "Sources"
        )
    ]
)
