//
//  Selector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Selector: Sendable {
    var store: Store { get }
}

extension Selector {
    public func select<Selection: FluxArchitecture.Selection>(_ selection: Selection) -> Selection.State {
        store.select(selection)
    }

    public func select<State>(_ keyPath: KeyPath<Store, State>) -> State {
        store.select(KeyPathSelection(keyPath: keyPath))
    }

    public func select<State: FluxArchitecture.SharedState>(_ type: State.Type) -> State {
        store.select(StateTypeSelection())
    }

    public func select<SharedState: FluxArchitecture.SharedState, State>(_ map: @escaping (SharedState) -> State) -> State {
        store.select(StateMapSelection(map: map))
    }

    public func select<SharedState: FluxArchitecture.SharedState, State>(_ keyPath: KeyPath<SharedState, State>) -> State {
        store.select(StateKeyPathSelection(keyPath: keyPath))
    }
}
