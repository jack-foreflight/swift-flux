//
//  Selector.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol Selector<State> {
    associatedtype State
    func body(store: Store) -> State
}

//@propertyWrapper
//public struct AppSelector<Value> {
//    private let value: () -> Value
//
//    public init(_ keyPath: KeyPath<AppEnvironmentValues, Value>) {
//        self.value = { AppEnvironmentValues.current[keyPath: keyPath] }
//    }
//
//    public init<Key: AppEnvironmentKey>(_ key: Key.Type) where Value == Key.Value {
//        self.value = { AppEnvironmentValues.current[key] }
//    }
//
//    public init(
//        _ value: Value.Type,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) where Value: SharedState {
//        self.value = { AppEnvironmentValues.current[value, file, line] }
//    }
//
//    public var wrappedValue: Value { value() }
//}
