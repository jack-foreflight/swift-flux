//
//  WithEnvironment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

// MARK: withEnvironment(_: AppEnvironmentValues) -> Void)
@discardableResult public func withEnvironment<Result>(
    _ newValues: AppEnvironmentValues,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    let operationScoped = AppEnvironmentValues.current.merging(newValues)
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ newValues: AppEnvironmentValues,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    let operationScoped = AppEnvironmentValues.current.merging(newValues)
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

// MARK: withEnvironment(_: WritableKeyPath<AppEnvironmentValues, Value>)
@discardableResult public func withEnvironment<Value, Result>(
    _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
    value: Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[keyPath: keyPath] = value
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Value, Result>(
    _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
    value: Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[keyPath: keyPath] = value
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

// MARK: withEnvironment(_: AppEnvironmentKey.Type)
@discardableResult public func withEnvironment<Key: AppEnvironmentKey, Result>(
    _ key: Key.Type,
    value: Key.Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[key] = value
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Key: AppEnvironmentKey, Result>(
    _ key: Key.Type,
    value: Key.Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[key] = value
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

// MARK: withEnvironment(_: (inout AppEnvironmentValues) -> Void)
@discardableResult public func withEnvironment<Result>(
    _ updateValues: (inout AppEnvironmentValues) -> Void,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    updateValues(&operationScoped)
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withEnvironment<Result>(
    _ updateValues: (inout AppEnvironmentValues) -> Void,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    updateValues(&operationScoped)
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
