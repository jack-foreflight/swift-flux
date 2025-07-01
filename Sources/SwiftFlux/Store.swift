//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@MainActor
public final class Store: Sendable {
    private let injectionValues: InjectionValues

    public nonisolated init() {
        self.injectionValues = InjectionValues()
    }

    nonisolated init(injectionValues: InjectionValues) {
        self.injectionValues = injectionValues
    }

    public func select<Selection: SwiftFlux.Selection>(_ selection: @autoclosure () -> Selection) -> Selection.State {
        withStore(self) {
            withInjection(injectionValues) {
                selection().select()
            }
        }
    }

    public func dispatch(_ action: @autoclosure () -> some Action) {
        withStore(self) {
            withInjection(injectionValues) {
                execute(action())
            }
        }
    }

    public func handle(_ effect: @autoclosure () -> some Effect) {

    }

    private func execute(_ action: some Action) {
        Injected[\.events].willDispatch(action)
        defer { Injected[\.events].didDispatch(action) }
        let operations = action.flattened
        do {
            if operations.awaitable {
                Task { try await operations.executeAll() }
            } else {
                try operations.executeAll()
            }
        } catch {
            // TODO: Handle Error Placeholder
        }
    }
}
