//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@MainActor
public final class Store {
    let stateRegistrar: StateRegistrar = StateRegistrar()
    var environment: AppEnvironmentValues = AppEnvironmentValues()

    public nonisolated init() {}
}
