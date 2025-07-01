//
//  Injected.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@propertyWrapper
public struct Injected<Value> {
    let value: () -> Value
    public var wrappedValue: Value { value() }

    public init(_ keyPath: KeyPath<InjectionValues, Value>) {
        self.value = { InjectionValues.current[keyPath: keyPath] }
    }

    public init<Key: Injection>(_ key: Key.Type) where Value == Key.Value {
        self.value = { InjectionValues.current[key] }
    }

    public init(
        _ store: Store.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value == Store {
        self.value = { InjectionValues.current[store, file, line] }
    }

    public init(
        _ state: Value.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value: Sendable {
        self.value = { InjectionValues.current[state, file, line] }
    }

    public static subscript<Key: Injection>(key: Key.Type) -> Value where Key.Value == Value {
        InjectionValues.current[key]
    }

    public static subscript(keyPath: KeyPath<InjectionValues, Value>) -> Value {
        InjectionValues.current[keyPath: keyPath]
    }

    public static subscript(state: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value where Value: Sendable {
        InjectionValues.current[state, file, line]
    }
}
