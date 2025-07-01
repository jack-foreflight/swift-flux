//
//  StoreBuilder.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

struct State1: Sendable {

}

struct State2: Sendable {

}

extension Store {
    public static nonisolated func configure() -> StoreBuilder {
        StoreBuilder()
    }

    public static nonisolated func build() -> Store {
        Store()
    }
}

public class StoreBuilder {
    private var injectionValues: InjectionValues = InjectionValues()

    public func withState<each State: Sendable>(_ state: repeat each State) -> StoreBuilder {
        for state in repeat each state {
            injectionValues.register(state)
        }
        return self
    }

    public func withState<each State: Sendable>(@StateBuilder _ builder: () -> (repeat each State)) -> StoreBuilder {
        for state in repeat each builder() {
            injectionValues.register(state)
        }
        return self
    }

    public func withEffects<each Effect: SwiftFlux.Effect>(_ effect: repeat each Effect) -> StoreBuilder {
        for effect in repeat each effect {
            //            injectionValues.register(state)
        }
        return self
    }

    public func withEffects<each Effect: SwiftFlux.Effect>(@EffectsBuilder _ builder: () -> (repeat each Effect)) -> StoreBuilder {
        //        for state in repeat each builder() {
        //            injectionValues.register(state)
        //        }
        self
    }

    public func withInjection(_ builder: (inout InjectionValues) -> Void) -> StoreBuilder {
        var injectionValues = injectionValues
        builder(&injectionValues)
        return self
    }

    public func build() -> Store {
        Store(injectionValues: injectionValues)
    }

    @resultBuilder
    struct StateBuilder {
        public static func buildBlock<each State: Sendable>(_ components: repeat each State) -> (repeat each State) {
            (repeat each components)
        }
    }

    @resultBuilder
    struct EffectsBuilder {
        public static func buildBlock<each Effect: SwiftFlux.Effect>(_ components: repeat each Effect) -> (repeat each Effect) {
            (repeat each components)
        }
    }
}
