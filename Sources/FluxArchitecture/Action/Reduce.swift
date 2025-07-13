//
//  Reduce.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

public struct Reduce<State: SharedState>: Action {
    @Injected(State.self) private var state
    private let operation: (State) -> Void

    init(_ operation: @escaping (State) -> Void) {
        self.operation = operation
    }

    public var body: some Action {
        Sync { operation(state) }
    }
}
