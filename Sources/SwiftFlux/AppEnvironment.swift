//
//  AppEnvironment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/19/25.
//

import Foundation

public protocol AppEnvironmentKey {
    typealias Container = AppEnvironmentValues
    associatedtype Value
    static func build(container: Container) -> Value
}

@MainActor
@propertyWrapper
public struct AppEnvironment<Value> {
    let value: () -> Value
    public var wrappedValue: Value { value() }

    public init(_ keyPath: KeyPath<AppEnvironmentValues, Value>) {
        self.value = { AppEnvironmentValues.current[keyPath: keyPath] }
    }

    public init<Key: AppEnvironmentKey>(_ key: Key.Type) where Value == Key.Value {
        self.value = { AppEnvironmentValues.current[key] }
    }

    public init(
        _ store: Store.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Store {
        self.value = { AppEnvironmentValues.current[store, file, line] }
    }

    public init(
        _ state: Value.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value: Sendable {
        self.value = { AppEnvironmentValues.current[state, file, line] }
    }
}

@MainActor
public struct AppEnvironmentValues: Sendable {
    private var storage: [ObjectIdentifier: Any] = [:]

    public nonisolated init() {}

    public func merging(_ other: Self) -> Self {
        var current = self
        current.storage.merge(other.storage) { $1 }
        return current
    }

    public subscript<Key: AppEnvironmentKey>(key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.build(container: self) }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    public subscript(store: Store.Type, file: StaticString = #file, line: UInt = #line) -> Store {
        get { resolve(store, file: file, line: line) }
        set { register(newValue) }
    }

    public subscript<State: Sendable>(state: State.Type, file: StaticString = #file, line: UInt = #line) -> State {
        get { resolve(state, file: file, line: line) }
        set { register(newValue) }
    }

    private func resolve<Value: Sendable>(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value {
        guard let value = storage[ObjectIdentifier(value)] as? Value else {
            let typeName = String(describing: value)
            let message = "No Observable object of type \(typeName) found. An Action.environment(_:) for \(typeName) may be missing as an ancestor of this action."

            #if DEBUG
                fatalError(message, file: file, line: line)
            #else
                // In release builds, provide a more graceful failure
                preconditionFailure(message)
            #endif
        }
        return value
    }

    private mutating func register<Value: Sendable>(_ newValue: Value) {
        storage[ObjectIdentifier(Value.self)] = newValue
    }
}

extension AppEnvironmentValues {
    @TaskLocal public static var current = AppEnvironmentValues()
}

#if canImport(SwiftUI)
    import SwiftUI

    extension AppEnvironmentKey where Self: SwiftUI.EnvironmentKey {
        public static func build(container: Container) -> Value { Self.defaultValue }
    }
#endif

@MainActor
@discardableResult
public func withEnvironment<Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Value, Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Value, Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Key: AppEnvironmentKey, Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Key: AppEnvironmentKey, Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Result: Sendable>(
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

@MainActor
@discardableResult
public func withEnvironment<Result: Sendable>(
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

@MainActor
@discardableResult
public func withState<State: Sendable, Result: Sendable>(
    _ state: State,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[State.self] = state
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult
public func withState<State: Sendable, Result: Sendable>(
    _ state: State,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[State.self] = state
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@MainActor
@discardableResult public func withStore<Result>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[Store.self] = store
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult public func withStore<Result: Sendable>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[Store.self] = store
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
