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
        Store()
    }
}

public class StoreBuilder {
    private var injectionValues: InjectionValues = InjectionValues()

    public func withState() -> StoreBuilder {
        self
    }

    public func withInjection() -> StoreBuilder {
        self
    }

    public func withEffects() -> StoreBuilder {
        self
    }

    public func build() -> Store {
        fatalError()
    }
}
