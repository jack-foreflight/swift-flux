//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import FluxInjection
import Foundation

@MainActor
public final class Store: Sendable {
    public nonisolated static let defaultValue: Store = Store()
    private var injectionValues: InjectionValues

    public nonisolated init() {
        injectionValues = InjectionValues()
    }

    public func select<Selection: FluxArchitecture.Selection>(_ selection: @autoclosure () -> Selection) -> Selection.State {
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
        withStore(self) {
            withInjection(injectionValues) {
                execute(effect())
            }
        }
    }

    private func register(_ effects: [any Effect]) {
        withStore(self) {
            withInjection(injectionValues) {
                for effect in effects {
                    effect.event.register()
                }
            }
        }
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

    private func execute(_ effect: some Effect) {
        let operations = effect.body.flattened
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
