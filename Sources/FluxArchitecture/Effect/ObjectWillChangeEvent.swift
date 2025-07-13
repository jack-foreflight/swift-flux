//
//  ObjectWillChangeEvent.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

#if canImport(Combine)
    import Combine

    public struct ObjectWillChangeEvent<State: ObservableObject & SharedState, Effect: FluxArchitecture.Effect>: Event {
        @Injected(State.self) private var state
        @Injected(Store.self) private var store
        @Injected(\.events) private var events

        private let effect: (State) -> Effect

        init(effect: @escaping (State) -> Effect) {
            self.effect = effect
        }

        public func register() {
            events.register {
                state.objectWillChange.sink { _ in
                    store.handle(effect(state))
                }
            }
        }
    }
#endif
