// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-flux",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SwiftFlux",
            targets: ["SwiftFlux"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1")
    ],
    targets: [
        .macro(
            name: "SwiftFluxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftFlux",
            dependencies: ["SwiftFluxMacros"]
        ),
        .testTarget(
            name: "SwiftFluxTests",
            dependencies: ["SwiftFlux"]
        ),
    ]
)
