//
//  StateMapSelection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

public struct StateMapSelection<SharedState: SwiftFlux.SharedState, State>: Selection {
    @Injected(SharedState.self) private var state
    private let map: (SharedState) -> State

    public init(map: @escaping (SharedState) -> State) {
        self.map = map
    }

    public func select() -> State { map(state) }
}
