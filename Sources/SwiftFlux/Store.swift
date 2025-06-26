//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@MainActor
@Observable
public final class Store: SharedState {
    private let stateRegistrar: StateRegistrar = StateRegistrar()
    @ObservationIgnored private var environment: AppEnvironmentValues = AppEnvironmentValues()

    public init() {}

    public func dispatch(_ action: @autoclosure () -> some Action) {
        withStore(self) { action().sync() }
    }

    func register(_ task: () -> Task<Void, Never>) {
        _ = task()
    }

    public func register(in store: Store) {

    }

    public func register<State: SharedState>(state: State) {
        stateRegistrar.register(state: state)
    }

    func resolve<State: SharedState>() -> State {
        resolve(State.self)
    }

    func resolve<State: SharedState>(_ type: State.Type) -> State {
        guard let state = stateRegistrar.resolve(type) else {
            // Log error
            preconditionFailure()
        }
        return state
    }

    internal class StateRegistrar {
        private var state: [AnyHashable: any SharedState] = [:]
        private var effects: [AnyHashable: [any Effect]] = [:]

        func register<each Effect: SwiftFlux.Effect>(effects: repeat each Effect) {
            for effect in repeat each effects {
                register(effect: effect)
            }
        }

        func register<State: SharedState>(effect: some Effect<State>) {
            //            self.effects[State.id]?.append(effect)
        }

        func register<State: SharedState>(state: State) {
            //            self.state[State.id] = state
        }

        func resolve<State: SharedState>(_ type: State.Type) -> State? {
            nil
            //            self.state[State.id] as? State
        }
    }
}
