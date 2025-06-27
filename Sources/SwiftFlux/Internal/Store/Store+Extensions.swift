//
//  Store+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation

extension Store {
    public func dispatch(_ action: @autoclosure () -> some Action) {
        withStore(self) { action().sync() }
    }

    public func register(_ task: () -> Task<Void, Never>) {
        _ = task()
    }

    public func register(in store: Store) {

    }

    public func register<State: SharedState>(state: State) {
        stateRegistrar.register(state: state)
    }

    private func resolve<State: SharedState>() -> State {
        resolve(State.self)
    }

    private func resolve<State: SharedState>(_ type: State.Type) -> State {
        guard let state = stateRegistrar.resolve(type) else {
            // Log error
            preconditionFailure()
        }
        return state
    }

    class StateRegistrar {
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
