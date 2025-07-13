//
//  StoreBuilder.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import FluxInjection
import Foundation

extension Store {
    private static var configured: Bool = false
    public func configure() -> StoreBuilder {
        guard !Self.configured else { fatalError("Store has already been configured, you may only call configure() once.") }
        defer { Self.configured = true }
        return StoreBuilder(with: self)
    }
}

public final class StoreBuilder {
    private var store: Store
    private var injectionValues: InjectionValues = InjectionValues()
    private var effects: [any Effect] = []

    init(with store: Store) {
        self.store = store
    }

    public func withInjection(_ builder: (inout InjectionValues) -> Void) -> StoreBuilder {
        var injectionValues = injectionValues
        builder(&injectionValues)
        return self
    }

    public func withState<each State: SharedState>(_ state: repeat each State) -> StoreBuilder {
        for state in repeat each state {
            injectionValues.register(state)
        }
        return self
    }

    public func withState<each State: SharedState>(@StateBuilder _ builder: @escaping () -> (repeat each State)) -> StoreBuilder {
        for state in repeat each builder() {
            injectionValues.register(state)
        }
        return self
    }

    public func withEffects<each Effect: FluxArchitecture.Effect>(effects: repeat each Effect) -> StoreBuilder {
        for effect in repeat each effects {
            self.effects.append(effect)
        }
        return self
    }

    public func withEffects<each Effect: FluxArchitecture.Effect>(@EffectsBuilder _ builder: () -> (repeat each Effect)) -> StoreBuilder {
        for effect in repeat each builder() {
            self.effects.append(effect)
        }
        return self
    }

    public func build() -> Store {
        store
        //        Store(injectionValues: injectionValues, effects: effects)
        //        nonisolated init(injectionValues: InjectionValues, effects: [any Effect]) {
        //            self.injectionValues = injectionValues
        //            Task {
        //                await register(effects)
        //            }
        //        }
    }

    @resultBuilder
    struct StateBuilder {
        static func buildBlock<each State: SharedState>(_ components: repeat each State) -> (repeat each State) {
            (repeat each components)
        }
    }

    @resultBuilder
    struct EffectsBuilder {
        static func buildBlock<each Effect: FluxArchitecture.Effect>(_ components: repeat each Effect) -> (repeat each Effect) {
            (repeat each components)
        }
    }
}
