//
//  Action+Environment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

extension Action {
    public func environment(_ store: Store) -> some Action {
        EnvironmentAction(store: store) { self }
    }

    public func environment(_ state: some SharedState) -> some Action {
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

private struct EnvironmentAction<Body: Action>: Action {
    private let build: () -> Body

    init(store: Store, build: @escaping () -> Body) {
        self.build = { withStore(store) { build() } }
    }

    init(state: some SharedState, build: @escaping () -> Body) {
        self.build = { withState(state) { build() } }
    }

    init<Value>(
        keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
        value: Value,
        build: @escaping () -> Body
    ) {
        self.build = { withEnvironment(keyPath, value: value) { build() } }
    }

    init<Key: AppEnvironmentKey>(
        key: Key.Type,
        value: Key.Value,
        build: @escaping () -> Body
    ) {
        self.build = { withEnvironment(key, value: value) { build() } }
    }

    var body: Body { build() }
}
