//
//  Injected.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@propertyWrapper
public struct Injected<Value> {
    private let value: () -> Value

    public init(_ keyPath: KeyPath<InjectionValues, Value>) {
        self.value = { Injected[keyPath] }
    }

    public init<Key: Injection>(_ key: Key.Type) where Value == Key.Value {
        self.value = { Injected[key] }
    }

    public init(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) where Value: Sendable {
        self.value = { Injected.resolve(value) }
    }

    public var wrappedValue: Value { value() }

    public static subscript(keyPath: KeyPath<InjectionValues, Value>) -> Value {
        InjectionValues.current[keyPath: keyPath]
    }

    public static subscript<Key: Injection>(key: Key.Type) -> Value where Key.Value == Value {
        InjectionValues.current[key]
    }

    public static func resolve(_ value: Value.Type, file: StaticString = #file, line: UInt = #line) -> Value where Value: Sendable {
        InjectionValues.current.resolve(value, file: file, line: line)
    }
}
