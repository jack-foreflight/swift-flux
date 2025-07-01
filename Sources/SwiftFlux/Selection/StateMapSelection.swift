//
//  StateMapSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateMapSelection<SharedState: Sendable, State>: Selection {
    private let map: (SharedState) -> State

    public init(map: @escaping (SharedState) -> State) {
        self.map = map
    }

    public func select(store: Store) -> State { map(store.resolve()) }
}
