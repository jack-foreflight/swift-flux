//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation
import SwiftUI

@MainActor
public final class Store {
    var environmentValues: AppEnvironmentValues = AppEnvironmentValues()

    public nonisolated init() {}

    public func resolve<State: Sendable>(_ state: State.Type = State.self) -> State {
        environmentValues[state]
    }

    public func dispatch(_ action: @autoclosure () -> some Action) {
        withStore(self) { execute(action()) }
    }

    private func execute(_ action: some Action) {
        let operations = action.flattened
        do {
            if operations.awaitable {
                Task { try await operations.executeAll() }
            } else {
                try operations.executeAll()
            }
        } catch {
            // Handle Error Placeholder
        }
    }
}

/// A macro that automatically implements AppState conformance and Observable behavior.
/// This macro generates the necessary observation infrastructure and automatic registration
/// of nested AppState properties.
@attached(member, names: named(store), named(dispatch))
@attached(extension, conformances: Selecting, Dispatching)
public macro StoreView() = #externalMacro(module: "SwiftFluxMacros", type: "StoreViewMacro")
