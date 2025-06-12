//
//  Registrable.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

/// A protocol for types that can register AppState objects.
public protocol Registrable {
    /// Registers an AppState object
    /// - Parameter state: The state object to register
    @MainActor func register<State: AppState>(state: State)
}

@MainActor final class StateRegistrar: Registrable {
    private var registry: [ObjectIdentifier: any AppState] = [:]

    internal func resolve<State: AppState>(state type: State.Type) -> State? {
        registry[ObjectIdentifier(State.self)] as? State
    }

    internal func register<State: AppState>(state: State) {
        let identifier = ObjectIdentifier(State.self)
        if registry[identifier] == nil {
            registry[identifier] = state
        }
    }
}
