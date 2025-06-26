//
//  Mutate.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public struct Mutate<State: SharedState>: Action {
    @AppEnvironment(State.self) private var state
    private let operation: (State) throws -> Void

    public init(_ operation: @escaping (State) throws -> Void) {
        self.operation = operation
    }

    public var body: some Action {
        Sync { try operation(state) }
    }
}
