//
//  Store+EnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    extension Store: EnvironmentKey {
        public static nonisolated let defaultValue: Store = Store.build()
    }

    extension EnvironmentValues {
        public var store: Store {
            get { self[Store.self] }
            set { self[Store.self] = newValue }
        }
    }
#endif
