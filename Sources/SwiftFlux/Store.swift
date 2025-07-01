//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@MainActor
public final class Store {
    var injection: InjectionValues = InjectionValues()

    public nonisolated init() {}

    public func resolve<State: Sendable>(_ state: State.Type = State.self) -> State {
        injection[state]
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
