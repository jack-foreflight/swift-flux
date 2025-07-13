//
//  InjectionValues.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation
import os

public struct InjectionValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public nonisolated init() {}

    public func merging(_ other: Self) -> Self {
        var current = self
        current.storage.merge(other.storage) { $1 }
        return current
    }

    public subscript<Key: Injection>(key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    public mutating func register<Value: Sendable>(_ newValue: Value) {
        storage[ObjectIdentifier(Value.self)] = newValue
    }

    public func resolve<Value: Sendable>(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value {
        guard let value = storage[ObjectIdentifier(value)] as? Value else {
            let typeName = String(describing: value)
            let message = "No Object of type \(typeName) found. An Injection for \(typeName) may be missing as an ancestor of this action."

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
