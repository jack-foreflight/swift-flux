// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CounterApp",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .executable(
            name: "CounterApp",
            targets: ["CounterApp"]
        )
    ],
    dependencies: [
        // Reference to the local SwiftFlux package
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "CounterApp",
            dependencies: [
                .product(name: "SwiftFlux", package: "swift-flux")
            ]
        )
    ]
)
