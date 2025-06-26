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

    public init(_ keyPath: KeyPath<AppEnvironmentValues, Value>) {
        self.value = { AppEnvironmentValues.current[keyPath: keyPath] }
    }

    public init<Key: AppEnvironmentKey>(_ key: Key.Type) where Value == Key.Value {
        self.value = { AppEnvironmentValues.current[key] }
    }

    public init(
        _ value: Value.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) where Value: SharedState {
        self.value = { AppEnvironmentValues.current[value, file, line] }
    }

    public var wrappedValue: Value { value() }
}

@freestanding(expression)
public macro AppEnvironment<Value>(_ keyPath: KeyPath<AppEnvironmentValues, Value>) -> Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")

@freestanding(expression)
public macro AppEnvironment<Key: AppEnvironmentKey>(_ key: Key.Type) -> Key.Value =
    #externalMacro(module: "SwiftFluxMacros", type: "AppEnvironmentMacro")
