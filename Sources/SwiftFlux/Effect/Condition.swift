//
//  Condition.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public protocol Condition {
    func evaluate(store: Store) -> Bool
}

extension Never: Condition {
    public func evaluate(store: Store) -> Bool { false }
}

extension Bool: Condition {
    public func evaluate(store: Store) -> Bool { self }
}

public struct OnChange<State>: Condition {
    public func evaluate(store: Store) -> Bool {
        true
    }
}
