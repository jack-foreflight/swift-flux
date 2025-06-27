//
//  Sequential.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

@resultBuilder
public struct Sequential: Action {
    @AppEnvironment(Store.self) private var store
    let actions: [any Action]

    private init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Sequential _ group: () -> Self) {
        self.actions = group().actions
    }

    public var body: Self { self }

    public func sync() {
        store.register { Task { await async() } }
    }

    public func async() async {
        for action in actions {
            await action.async()
        }
    }

    public static func buildBlock(_ actions: any Action...) -> Self {
        Sequential(actions)
    }

    public static func buildOptional(_ actions: [any Action]?) -> Self {
        Sequential(actions ?? [])
    }

    public static func buildEither(first actions: [any Action]) -> Self {
        Sequential(actions)
    }

    public static func buildEither(second actions: [any Action]) -> Self {
        Sequential(actions)
    }

    public static func buildArray(_ actions: [[any Action]]) -> Self {
        Sequential(actions.flatMap { $0 })
    }
}
