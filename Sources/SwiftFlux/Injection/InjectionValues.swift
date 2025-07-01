//
//  InjectionValues.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
public struct InjectionValues: Sendable {
    private var storage: [ObjectIdentifier: Any] = [:]

    public nonisolated init() {}

    public func merging(_ other: Self) -> Self {
        var current = self
        current.storage.merge(other.storage) { $1 }
        return current
    }

    public subscript<Key: Injection>(key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.inject(container: self) }
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
            let message = "No Object of type \(typeName) found. An Action.environment(_:) for \(typeName) may be missing as an ancestor of this action."

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

extension InjectionValues {
    @TaskLocal public static var current = InjectionValues()
}
