//
//  WillDispatchEvent.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public struct WillDispatchEvent<Action, Effect: FluxArchitecture.Effect>: Event {
    @Injected(Store.self) private var store
    @Injected(\.events) private var events

    private let effect: (Action) -> Effect

    init(effect: @escaping (Action) -> Effect) {
        self.effect = effect
    }

    public func register() {
        events.registerWillDispatch { action in
            if let action = action as? Action {
                store.handle(effect(action))
            }
        }
    }
}
