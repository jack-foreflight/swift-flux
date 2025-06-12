//
//  Dispatcher.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

/// A protocol for types that can dispatch actions to modify state.
public protocol Dispatcher {
    /// Dispatches a synchronous action
    /// - Parameter action: The action to execute
    @MainActor func dispatch(_ action: some Action)
    /// Dispatches an asynchronous action
    /// - Parameter action: The async action to execute
    @MainActor func dispatch(_ action: some AsyncAction)
}

@MainActor extension Dispatcher {
    /// Dispatches multiple actions using a result builder
    /// - Parameter actions: A closure that builds an array of actions
    public func dispatch(@ActionBuilder _ actions: () -> [any Action]) {
        for action in actions() {
            dispatch(action)
        }
    }
}
