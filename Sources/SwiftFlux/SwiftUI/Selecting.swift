//
//  Selecting.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Selecting {
    var store: Store { get }
}

extension Selecting {
    public func select<Selector: StateSelector>(_ selector: Selector) -> Selector.ViewState {
        selector.select(store: store)
    }

    public func select<ViewState: Sendable>(_ keyPath: KeyPath<Store, ViewState>) -> ViewState {
        KeyPathSelector(keyPath: keyPath).select(store: store)
    }

    public func select<ViewState: Sendable>(_ type: ViewState.Type) -> ViewState {
        StateTypeSelector().select(store: store)
    }

    public func select<State: Sendable, ViewState>(_ map: @escaping (State) -> ViewState) -> ViewState {
        StateMapSelector(map: map).select(store: store)
    }

    public func select<State: Sendable, ViewState>(_ keyPath: KeyPath<State, ViewState>) -> ViewState {
        StateKeyPathSelector(keyPath: keyPath).select(store: store)
    }
}
