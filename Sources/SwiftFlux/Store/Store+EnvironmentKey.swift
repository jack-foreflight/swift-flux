//
//  Store+EnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import SwiftUI

extension Store: EnvironmentKey {
    public static nonisolated let defaultValue: Store = Store()
}

extension EnvironmentValues {
    public var store: Store {
        get { self[Store.self] }
        set { self[Store.self] = newValue }
    }
}
