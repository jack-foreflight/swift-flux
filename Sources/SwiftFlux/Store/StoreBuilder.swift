//
//  StoreBuilder.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Store {
    public static nonisolated func configure() -> StoreBuilder {
        StoreBuilder()
    }

    public static nonisolated func build() -> Store {
        Store.configure().build()
    }
}

public class StoreBuilder {
    private var injectionValues: InjectionValues = InjectionValues()
    private var effects: [any Effect] = []

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

    public func withEffects<each Effect: SwiftFlux.Effect>(effects: repeat each Effect) -> StoreBuilder {
        for effect in repeat each effects {
            self.effects.append(effect)
        }
        return self
    }

    public func withEffects<each Effect: SwiftFlux.Effect>(@EffectsBuilder _ builder: () -> (repeat each Effect)) -> StoreBuilder {
        for effect in repeat each builder() {
            self.effects.append(effect)
        }
        return self
    }

    public func build() -> Store {
        Store(injectionValues: injectionValues, effects: effects)
    }

    @resultBuilder
    struct StateBuilder {
        static func buildBlock<each State: SharedState>(_ components: repeat each State) -> (repeat each State) {
            (repeat each components)
        }
    }

    @resultBuilder
    struct EffectsBuilder {
        static func buildBlock<each Effect: SwiftFlux.Effect>(_ components: repeat each Effect) -> (repeat each Effect) {
            (repeat each components)
        }
    }
}
