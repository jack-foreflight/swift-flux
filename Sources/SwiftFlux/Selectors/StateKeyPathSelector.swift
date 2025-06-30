//
//  StateKeyPathSelector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateKeyPathSelector<State: Sendable, ViewState>: StateSelector {
    @AppEnvironment(State.self) private var state
    private let keyPath: KeyPath<State, ViewState>

    public init(keyPath: KeyPath<State, ViewState>) {
        self.keyPath = keyPath
    }

    public func select(store: Store) -> ViewState { store.resolve(State.self)[keyPath: keyPath] }
}
