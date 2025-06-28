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
    public nonisolated init() {}

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

extension Store: AppEnvironmentKey, EnvironmentKey {
    public static nonisolated let defaultValue: Store = Store()
    public static nonisolated func build(container: Container) -> Store { Store() }
}

extension EnvironmentValues {
    public var store: Store {
        get { self[Store.self] }
        set { self[Store.self] = newValue }
    }
}
