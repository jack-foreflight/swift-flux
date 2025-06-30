//
//  StateTypeSelector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateTypeSelector<State: Sendable>: StateSelector {
    public init() {}

    public func select(store: Store) -> State { store.resolve() }
}
