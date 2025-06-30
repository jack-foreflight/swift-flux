//
//  StateMapSelector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateMapSelector<State: Sendable, ViewState>: StateSelector {
    private let map: (State) -> ViewState

    public init(map: @escaping (State) -> ViewState) {
        self.map = map
    }

    public func select(store: Store) -> ViewState { map(store.resolve()) }
}
