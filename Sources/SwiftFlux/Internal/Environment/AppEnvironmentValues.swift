//
//  AppEnvironmentValues.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation
import os

public struct AppEnvironmentValues: Sendable {
    private let storage = OSAllocatedUnfairLock(uncheckedState: [ObjectIdentifier: Any]())

    public func merging(_ other: Self) -> Self {
        let other = other.storage.withLockUnchecked { $0 }
        let current = self
        current.storage.withLockUnchecked { $0.merge(other, uniquingKeysWith: { $1 }) }
        return current
    }

    public subscript<Key: AppEnvironmentKey>(key: Key.Type) -> Key.Value {
        get { storage.withLockUnchecked { $0[ObjectIdentifier(key)] } as? Key.Value ?? key.build(container: self) }
        set { storage.withLockUnchecked { $0[ObjectIdentifier(key)] = newValue } }
    }

    public subscript(store: Store.Type, file: StaticString = #file, line: UInt = #line) -> Store {
        get { resolve(store, file: file, line: line) }
        set { register(newValue) }
    }

    public subscript<State: SharedState>(state: State.Type, file: StaticString = #file, line: UInt = #line) -> State {
        get { resolve(state, file: file, line: line) }
        set { register(newValue) }
    }

    private func resolve<Value: Sendable>(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value {
        guard let value = storage.withLockUnchecked({ $0[ObjectIdentifier(value)] }) as? Value else {
            fatalError("No Observable object of type \(value) found. An Action.environment(_:) for \(value) may be missing as an ancestor of this action.", file: file, line: line)
        }
        return value
    }

    private func register<Value: Sendable>(_ newValue: Value) {
        storage.withLock { $0[ObjectIdentifier(Value.self)] = newValue }
    }

    enum Context {
        case live
        case test
        case preview
    }

    enum Scope {
        case singleton
        case scoped
        case transient
    }
}

extension AppEnvironmentValues {
    @TaskLocal public static var current = AppEnvironmentValues()
}
