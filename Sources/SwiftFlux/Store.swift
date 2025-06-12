//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation
@_exported import Observation

/// The central store that manages application state and coordinates action dispatching.
@MainActor
@Observable
public final class Store<State: AppState> {
    /// The root state object managed by this store
    public let state: State
    @ObservationIgnored private let registrar: StateRegistrar
    @ObservationIgnored private var activeTasks: [ObjectIdentifier: Task<Void, Never>] = [:]

    /// Creates a new store with the given root state
    /// - Parameter state: The root state object to manage
    public init(_ state: State) {
        self.state = state
        self.registrar = StateRegistrar()
        state.register(with: registrar)
    }

    private func resolve<S: AppState>() -> S? {
        registrar.resolve(state: S.self)
    }

    private func resolve<S: AppState>(_ type: S.Type) -> S? {
        registrar.resolve(state: type)
    }
}

extension Store: Selectable {}

extension Store: Registrable {
    public func register<S: AppState>(state: S) {
        registrar.register(state: state)
    }
}

extension Store: Dispatcher {
    public func dispatch<A: Action>(_ action: A) {
        guard let state = resolve(A.State.self) else { return }
        action.operation(state: state)
    }

    /// Dispatches an asynchronous action by creating a new task and tracking it
    /// - Parameter action: The async action to execute
    /// - Note: Each async action type can only have one active task at a time
    public func dispatch<A: AsyncAction>(_ action: A) {
        guard let store = self as? Store<A.State> else { return }
        activeTasks[ObjectIdentifier(A.self)] = Task { await action.operation(store: store) }
    }

    /// Cancels all currently running async actions
    public func cancelAllActions() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}
