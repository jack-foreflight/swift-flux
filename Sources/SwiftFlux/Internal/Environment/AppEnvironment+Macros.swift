//
//  AppEnvironment+Macros.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation

@freestanding(expression)
public macro AppEnvironment<Value>(_ keyPath: KeyPath<AppEnvironmentValues, Value>) -> Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")

@freestanding(expression)
public macro AppEnvironment<Key: AppEnvironmentKey>(_ key: Key.Type) -> Key.Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")

/// Marks a struct as an environment value, automatically generating AppEnvironmentKey conformance
/// and convenience accessors on AppEnvironmentValues.
///
/// Usage:
/// ```swift
/// // Basic usage - resolves as concrete type
/// @AppEnvironmentValue
/// struct APIClient {
///     let baseURL: String
///     init(baseURL: String = "https://api.example.com") {
///         self.baseURL = baseURL
///     }
/// }
///
/// // Protocol-based resolution
/// protocol NetworkClientProtocol {
///     func request(_ endpoint: String) async throws -> Data
/// }
///
/// @AppEnvironmentValue(NetworkClientProtocol.self)
/// struct APIClient: NetworkClientProtocol {
///     func request(_ endpoint: String) async throws -> Data {
///         // Implementation
///     }
/// }
/// ```
///
/// The macro generates:
/// - AppEnvironmentKey conformance with appropriate Value type
/// - Convenience property on AppEnvironmentValues for easy access
/// - Default value initialization
@attached(member, names: named(defaultValue))
@attached(extension, conformances: AppEnvironmentKey, names: named(Value), arbitrary)
public macro AppEnvironmentValue(_ protocolType: Any.Type) = 
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentValueMacro")

@attached(member, names: named(defaultValue))
@attached(extension, conformances: AppEnvironmentKey, names: named(Value), arbitrary)
public macro AppEnvironmentValue() = 
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentValueMacro")
