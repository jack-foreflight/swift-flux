//
//  StateTypeSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateTypeSelection<State: Sendable>: Selection {
    @Injected(State.self) private var state
    public init() {}
    public func select() -> State { state }
}
