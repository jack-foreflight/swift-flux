//
//  DidChangeEvent.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation
import os

public struct DidChangeEvent<State: SharedState & Equatable, Effect: FluxArchitecture.Effect>: Event {
    private let previous: OSAllocatedUnfairLock<State?> = .init(initialState: nil)
    @Injected(State.self) private var state
    @Injected(Store.self) private var store
    @Injected(\.events) private var events

    private let effect: (State) -> Effect

    init(effect: @escaping (State) -> Effect) {
        self.effect = effect
    }

    public func register() {
        events.registerDidDispatch { _ in
            let previousValue = previous.withLock { $0 }
            let nextValue = state
            previous.withLock { $0 = nextValue }
            if previousValue != nextValue {
                store.handle(effect(state))
            }
        }
    }
}
