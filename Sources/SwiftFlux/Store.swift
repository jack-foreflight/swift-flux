//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@MainActor
public final class Store {
    public var environmentValues: AppEnvironmentValues = AppEnvironmentValues()

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

#if canImport(SwiftUI)
    import SwiftUI

    extension Store: AppEnvironmentKey, ViewEnvironmentKey {
        public static nonisolated let defaultValue: Store = Store()
    }

    extension EnvironmentValues {
        public var store: Store {
            get { self[Store.self] }
            set { self[Store.self] = newValue }
        }
    }
#endif
