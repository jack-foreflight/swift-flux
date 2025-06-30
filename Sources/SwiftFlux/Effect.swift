//
//  Effect.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
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

public protocol Effect {
    associatedtype Condition: SwiftFlux.Condition
    associatedtype Body: Action

    var condition: Condition { get }
    var body: Body { get }
}

extension Effect where Condition == Bool {
    public static var always: Condition { true }
    public static var never: Condition { false }
}
