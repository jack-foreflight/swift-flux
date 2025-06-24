//
//  AppEnvironment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/19/25.
//

import Foundation

@propertyWrapper
public struct AppEnvironment<Value> {
    private let value: () -> Value
    private let operationScoped: AppEnvironmentValues

    /// Creates an injected property wrapper for accessing dependencies
    /// - Parameters:
    ///   - keyPath: The key path to the dependency in InjectedValues
    ///   - immediate: Whether to initialize the value immediately (default: false)
    public init(_ keyPath: KeyPath<AppEnvironmentValues, Value>) {
        self.value = { AppEnvironmentValues.current[keyPath: keyPath] }
        self.operationScoped = AppEnvironmentValues.current
    }

    public init<Key: AppEnvironmentKey>(_ key: Key.Type) where Value == Key.Value {
        self.value = { AppEnvironmentValues.current[key] }
        self.operationScoped = AppEnvironmentValues.current
    }

    /// The injected dependency value, resolved with proper scope inheritance
    public var wrappedValue: Value {
        AppEnvironmentValues.$current.withValue(
            AppEnvironmentValues.current.merging(operationScoped)
        ) {
            value()
        }
    }
}

public protocol AppEnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct AppEnvironmentValues {
    private var storage: [ObjectIdentifier: Any] = [:]

    public func merging(_ other: Self) -> Self {
        var values = self
        values.storage.merge(other.storage, uniquingKeysWith: { $1 })
        return values
    }

    public subscript<Key: AppEnvironmentKey>(key: Key.Type) -> Key.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? Key.Value {
                return value
            }
            return key.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

extension AppEnvironmentValues {
    @TaskLocal public static var current = AppEnvironmentValues()

    public static subscript<Key: AppEnvironmentKey>(key: Key.Type) -> Key.Value {
        if let value = current.storage[ObjectIdentifier(key)] as? Key.Value {
            return value
        }
        return key.defaultValue
    }
}

@discardableResult public func withEnvironment<Value, Result>(
    _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
    value: Value,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[keyPath: keyPath] = value
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ updateValues: (inout AppEnvironmentValues) -> Void,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    updateValues(&operationScoped)
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ newValues: AppEnvironmentValues,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () throws -> Result
) rethrows -> Result {
    let operationScoped = AppEnvironmentValues.current.merging(newValues)
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Value, Result>(
    _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
    value: Value,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[keyPath: keyPath] = value
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ updateValues: (inout AppEnvironmentValues) -> Void,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    updateValues(&operationScoped)
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ newValues: AppEnvironmentValues,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    operation: () async throws -> Result
) async rethrows -> Result {
    let operationScoped = AppEnvironmentValues.current.merging(newValues)
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@freestanding(expression)
public macro AppEnvironment<Value>(_ keyPath: KeyPath<AppEnvironmentValues, Value>) -> Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")

@freestanding(expression)
public macro AppEnvironment<Key: AppEnvironmentKey>(_ key: Key.Type) -> Key.Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")
