//
//  Selector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Selector {
    var store: Store { get }
}

extension Selector {
    public func select<Selection: SwiftFlux.Selection>(_ selector: Selection) -> Selection.State {
        selector.select(store: store)
    }

    public func select<State>(_ keyPath: KeyPath<Store, State>) -> State {
        KeyPathSelection(keyPath: keyPath).select(store: store)
    }

    public func select<State: Sendable>(_ type: State.Type) -> State {
        StateTypeSelection().select(store: store)
    }

    public func select<SharedState: Sendable, State>(_ map: @escaping (SharedState) -> State) -> State {
        StateMapSelection(map: map).select(store: store)
    }

    public func select<SharedState: Sendable, State>(_ keyPath: KeyPath<SharedState, State>) -> State {
        StateKeyPathSelection(keyPath: keyPath).select(store: store)
    }
}
