//
//  Selector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol StateSelector<ViewState> {
    associatedtype ViewState
    func select() -> ViewState
}

struct KeyPathSelector<State: Sendable>: StateSelector {
    @AppEnvironment(Store.self) private var store
    private let keyPath: KeyPath<Store, State>

    init(keyPath: KeyPath<Store, State>) {
        self.keyPath = keyPath
    }

    func select() -> State { store[keyPath: keyPath] }
}

struct StateTypeSelector<State: Sendable>: StateSelector {
    @AppEnvironment(State.self) private var state
    func select() -> State { state }
}

struct StateMapSelector<State: Sendable, ViewState>: StateSelector {
    @AppEnvironment(State.self) private var state
    private let map: (State) -> ViewState

    init(map: @escaping (State) -> ViewState) {
        self.map = map
    }

    func select() -> ViewState { map(state) }
}

struct StateKeyPathSelector<State: Sendable, ViewState>: StateSelector {
    @AppEnvironment(State.self) private var state
    private let keyPath: KeyPath<State, ViewState>

    init(keyPath: KeyPath<State, ViewState>) {
        self.keyPath = keyPath
    }

    func select() -> ViewState { state[keyPath: keyPath] }
}

@MainActor
@propertyWrapper
public struct Select<ViewState> {
    private let selector: any StateSelector<ViewState>

    public init<Selector: StateSelector>(_ selector: Selector) where ViewState == Selector.ViewState {
        self.selector = selector
    }

    public init(_ keyPath: KeyPath<Store, ViewState>) where ViewState: Sendable {
        self.selector = KeyPathSelector(keyPath: keyPath)
    }

    public init(_ state: ViewState.Type) where ViewState: Sendable {
        self.selector = StateTypeSelector<ViewState>()
    }

    public init<State: Sendable>(_ map: @escaping (State) -> ViewState) {
        self.selector = StateMapSelector<State, ViewState>(map: map)
    }

    public init<State: Sendable>(_ keyPath: KeyPath<State, ViewState>) {
        self.selector = StateKeyPathSelector<State, ViewState>(keyPath: keyPath)
    }

    public var wrappedValue: ViewState { selector.select() }
}

#if canImport(SwiftUI)
    import SwiftUI

    extension View where Self: StateSelector {
        var state: ViewState { select() }
    }
#endif
