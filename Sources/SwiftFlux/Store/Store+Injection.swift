//
//  Store+Injection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

extension Store: Injection {
    public static nonisolated let defaultValue: Store = Store.build()
}

extension InjectionValues {
    public var store: Store {
        get { self[Store.self] }
        set { self[Store.self] = newValue }
    }
}
