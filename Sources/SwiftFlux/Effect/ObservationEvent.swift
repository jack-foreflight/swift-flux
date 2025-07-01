//
//  ObservationEvent.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

#if canImport(Observation)
    import Observation

    public struct ObservationEvent<State: Observable & Sendable, Effect: SwiftFlux.Effect>: Event {
        @Injected(State.self) private var state
        @Injected(Store.self) private var store
        @Injected(\.events) private var events

        private let effect: () -> Effect

        init(effect: @escaping () -> Effect) {
            self.effect = effect
        }

        public func register() {
            events.register(self)
            handle()
        }

        private func handle() {
            withObservationTracking {
                _ = state
            } onChange: {
                Task { @MainActor in
                    store.handle(effect())
                    register()
                }
            }
        }
    }
#endif
