//
//  InjectionValues.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public struct InjectionValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public nonisolated init() {}

    public func merging(_ other: Self) -> Self {
        var current = self
        current.storage.merge(other.storage) { $1 }
        return current
    }

    public subscript<Key: Injection>(key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.overrideOrDefault }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    public subscript<State: SharedState>(state: State.Type, file: StaticString = #file, line: UInt = #line) -> State {
        get { resolve(state, file: file, line: line) }
        set { register(newValue) }
    }

    mutating func register<Value: SharedState>(_ newValue: Value) {
        storage[ObjectIdentifier(Value.self)] = newValue
    }

    func resolve<Value: SharedState>(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value {
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
}

extension InjectionValues {
    @TaskLocal public static var current = InjectionValues()
}
