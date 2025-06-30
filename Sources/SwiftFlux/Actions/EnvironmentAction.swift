//
//  EnvironmentAction.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

public struct EnvironmentAction<Body: Action>: Action {
    let environment: AppEnvironmentValues
    let build: () -> Body

    init(store: Store, build: @escaping () -> Body) {
        self.environment = withStore(store) { AppEnvironmentValues.current }
        self.build = { withStore(store) { build() } }
    }

    init<State: Sendable>(state: State, build: @escaping () -> Body) {
        self.environment = withState(state) { AppEnvironmentValues.current }
        self.build = { withState(state) { build() } }
    }

    init<Value>(
        keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
        value: Value,
        build: @escaping () -> Body
    ) {
        self.environment = withEnvironment(keyPath, value: value) { AppEnvironmentValues.current }
        self.build = { withEnvironment(keyPath, value: value) { build() } }
    }

    init<Key: AppEnvironmentKey>(
        key: Key.Type,
        value: Key.Value,
        build: @escaping () -> Body
    ) {
        self.environment = withEnvironment(key, value: value) { AppEnvironmentValues.current }
        self.build = { withEnvironment(key, value: value) { build() } }
    }

    public var body: some Action { Operation.environment(environment, build()) }
}

extension Action {
    public func environment(_ store: Store) -> some Action {
        EnvironmentAction(store: store) { self }
    }

    public func environment<State: Sendable>(_ state: State) -> some Action {
        EnvironmentAction(state: state) { self }
    }

    public func environment<Value>(
        _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
        _ value: Value
    ) -> some Action {
        EnvironmentAction(keyPath: keyPath, value: value) { self }
    }

    public func environment<Key: AppEnvironmentKey>(
        _ key: Key.Type,
        _ value: Key.Value
    ) -> some Action {
        EnvironmentAction(key: key, value: value) { self }
    }
}
