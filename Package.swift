// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-flux",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(name: "FluxInjection", targets: ["FluxInjection"]),
        .library(name: "FluxObservation", targets: ["FluxObservation"]),
        .library(name: "FluxArchitecture", targets: ["FluxArchitecture"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1")
    ],
    targets: [
        .target(name: "FluxInjection"),
        .target(
            name: "FluxObservation",
            dependencies: ["FluxObservationMacros"]
        ),
        .target(
            name: "FluxArchitecture",
            dependencies: [
                "FluxInjection",
                "FluxArchitectureMacros",
            ]
        ),
        .macro(
            name: "FluxObservationMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "FluxArchitectureMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "FluxArchitectureTests",
            dependencies: ["FluxArchitecture"]
        ),
        .testTarget(
            name: "FluxObservationTests",
            dependencies: ["FluxObservation"]
        ),
    ]
)
