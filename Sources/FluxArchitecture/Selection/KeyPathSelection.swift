//
//  KeyPathSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct KeyPathSelection<State>: Selection {
    @Injected(Store.self) private var store
    private let keyPath: KeyPath<Store, State>

    public init(keyPath: KeyPath<Store, State>) {
        self.keyPath = keyPath
    }

    public func select() -> State { store[keyPath: keyPath] }
}
