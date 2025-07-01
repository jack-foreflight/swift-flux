//
//  WithInjection.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
@discardableResult
public func withInjection<Result: Sendable>(
    _ newValues: InjectionValues,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    let operationScoped = InjectionValues.current.merging(newValues)
    return try InjectionValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Result: Sendable>(
    _ newValues: InjectionValues,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    let operationScoped = InjectionValues.current.merging(newValues)
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Value, Result>(
    _ keyPath: WritableKeyPath<InjectionValues, Value>,
    value: Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped[keyPath: keyPath] = value
    return try InjectionValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Value, Result: Sendable>(
    _ keyPath: WritableKeyPath<InjectionValues, Value>,
    value: Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped[keyPath: keyPath] = value
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Key: Injection, Result: Sendable>(
    _ key: Key.Type,
    value: Key.Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped[key] = value
    return try InjectionValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Key: Injection, Result: Sendable>(
    _ key: Key.Type,
    value: Key.Value,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped[key] = value
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Result: Sendable>(
    _ updateValues: (inout InjectionValues) -> Void,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = InjectionValues.current
    updateValues(&operationScoped)
    return try InjectionValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@MainActor
@discardableResult
public func withInjection<Result: Sendable>(
    _ updateValues: (inout InjectionValues) -> Void,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = InjectionValues.current
    updateValues(&operationScoped)
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}

@MainActor
@discardableResult
public func withState<State: Sendable, Result>(
    _ state: State,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped[State.self] = state
    return try InjectionValues.$current.withValue(operationScoped) {
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
    var operationScoped = InjectionValues.current
    operationScoped[State.self] = state
    return try await InjectionValues.$current.withValue(operationScoped) {
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
    var operationScoped = InjectionValues.current
    operationScoped[Store.self] = store
    return try InjectionValues.$current.withValue(operationScoped) {
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
    var operationScoped = InjectionValues.current
    operationScoped[Store.self] = store
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
