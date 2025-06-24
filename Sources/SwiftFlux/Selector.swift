//
//  Selector.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol Selector<State, SelectedState> {
    associatedtype State: AppState
    associatedtype SelectedState
    func body(state: State) -> SelectedState
}

@dynamicMemberLookup
public protocol Selection<SelectedState> {
    associatedtype SelectedState
    subscript<Value>(dynamicMember keyPath: KeyPath<SelectedState, Value>) -> Value { get }
    func dispatch(_ action: some Action)
    func dispatch(_ action: some AsyncAction)
}

public struct Select<SelectedState>: Selection {
    private let store: Store
    private let state: (Store) -> SelectedState

    init(store: Store, state: @escaping (Store) -> SelectedState) {
        self.store = store
        self.state = state
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<SelectedState, Value>) -> Value {
        state(store)[keyPath: keyPath]
    }

    public func dispatch(_ action: some Action) {
        store.dispatch(action)
    }

    public func dispatch(_ action: some AsyncAction) {
        store.dispatch(action)
    }
}

extension Store {
    public func select<State: AppState>(_ type: State.Type) -> Select<State> {
        Select(store: self) { $0.resolve() }
    }

    public func select<Selector: SwiftFlux.Selector>(
        _ selector: Selector
    ) -> Select<Selector.SelectedState> {
        Select(store: self) { selector.body(state: $0.resolve()) }
    }

    public func select<State: AppState, SelectedState>(
        _ keyPath: KeyPath<State, SelectedState>
    ) -> Select<SelectedState> {
        Select(store: self) { $0.resolve(State.self)[keyPath: keyPath] }
    }

    public func select<State: AppState, SelectedState>(
        _ map: @escaping (State) -> SelectedState
    ) -> Select<SelectedState> {
        Select(store: self) { map($0.resolve()) }
    }
}
