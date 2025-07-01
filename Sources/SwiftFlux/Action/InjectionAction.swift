//
//  InjectionAction.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

public struct InjectionAction<Body: Action>: Action {
    let injection: InjectionValues
    let build: () -> Body

    init(store: Store, build: @escaping () -> Body) {
        self.injection = withStore(store) { InjectionValues.current }
        self.build = { withStore(store) { build() } }
    }

    init<State: Sendable>(state: State, build: @escaping () -> Body) {
        self.injection = withState(state) { InjectionValues.current }
        self.build = { withState(state) { build() } }
    }

    init<Value>(
        keyPath: WritableKeyPath<InjectionValues, Value>,
        value: Value,
        build: @escaping () -> Body
    ) {
        self.injection = withInjection(keyPath, value: value) { InjectionValues.current }
        self.build = { withInjection(keyPath, value: value) { build() } }
    }

    init<Key: Injection>(
        key: Key.Type,
        value: Key.Value,
        build: @escaping () -> Body
    ) {
        self.injection = withInjection(key, value: value) { InjectionValues.current }
        self.build = { withInjection(key, value: value) { build() } }
    }

    public var body: some Action { Operation.environment(injection, build()) }
}

extension Action {
    public func injecting(_ store: Store) -> some Action {
        InjectionAction(store: store) { self }
    }

    public func injecting<State: Sendable>(_ state: State) -> some Action {
        InjectionAction(state: state) { self }
    }

    public func injecting<Value>(
        _ keyPath: WritableKeyPath<InjectionValues, Value>,
        _ value: Value
    ) -> some Action {
        InjectionAction(keyPath: keyPath, value: value) { self }
    }

    public func injecting<Key: Injection>(
        _ key: Key.Type,
        _ value: Key.Value
    ) -> some Action {
        InjectionAction(key: key, value: value) { self }
    }

    public func environment(_ store: Store) -> some Action {
        InjectionAction(store: store) { self }
    }

    public func environment<State: Sendable>(_ state: State) -> some Action {
        InjectionAction(state: state) { self }
    }

    public func environment<Value>(
        _ keyPath: WritableKeyPath<InjectionValues, Value>,
        _ value: Value
    ) -> some Action {
        InjectionAction(keyPath: keyPath, value: value) { self }
    }

    public func environment<Key: Injection>(
        _ key: Key.Type,
        _ value: Key.Value
    ) -> some Action {
        InjectionAction(key: key, value: value) { self }
    }
}
