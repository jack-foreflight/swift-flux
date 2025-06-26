//
//  Parallel.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

@resultBuilder
public struct Parallel: Action {
    private let actions: [any Action]

    private init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Parallel _ group: () -> Self) {
        self.actions = group().actions
    }

    public var body: Self { self }

    public func sync() {
        for action in actions {
            action.sync()
        }
    }

    public func async() async { sync() }

    public static func buildBlock(_ actions: any Action...) -> Self {
        Parallel(actions)
    }

    public static func buildOptional(_ actions: [any Action]?) -> Self {
        Parallel(actions ?? [])
    }

    public static func buildEither(first actions: [any Action]) -> Self {
        Parallel(actions)
    }

    public static func buildEither(second actions: [any Action]) -> Self {
        Parallel(actions)
    }

    public static func buildArray(_ actions: [[any Action]]) -> Self {
        Parallel(actions.flatMap { $0 })
    }
}
