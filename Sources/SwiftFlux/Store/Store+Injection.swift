//
//  Store+Injection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

extension Store: Injection {
    public static nonisolated func inject(container: Container) -> Value {
        Store.build()
    }
}
