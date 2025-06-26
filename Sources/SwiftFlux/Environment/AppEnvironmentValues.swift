//
//  AppEnvironmentValues.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public struct AppEnvironmentValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public func merging(_ other: Self) -> Self {
        var values = self
        values.storage.merge(other.storage, uniquingKeysWith: { $1 })
        return values
    }

    public subscript<Key: AppEnvironmentKey>(key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    public subscript<State: SharedState>(
        key: State.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) -> State {
        get {
            guard let value = storage[ObjectIdentifier(key)] as? State else {
                fatalError(
                    "No Observable object of type \(key) found. An Action.environment(_:) for \(key) may be missing as an ancestor of this action.",
                    file: file,
                    line: line
                )
            }
            return value
        }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

extension AppEnvironmentValues {
    @TaskLocal public static var current = AppEnvironmentValues()
}
