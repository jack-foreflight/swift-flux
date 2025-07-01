//
//  StateTypeSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateTypeSelection<State: Sendable>: Selection {
    public init() {}

    public func select(store: Store) -> State { store.resolve() }
}
