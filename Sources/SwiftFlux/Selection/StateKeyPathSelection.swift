//
//  StateKeyPathSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateKeyPathSelection<SharedState: Sendable, State>: Selection {
    @Injected(SharedState.self) private var state
    private let keyPath: KeyPath<SharedState, State>

    public init(keyPath: KeyPath<SharedState, State>) {
        self.keyPath = keyPath
    }

    public func select(store: Store) -> State { store.resolve(SharedState.self)[keyPath: keyPath] }
}
