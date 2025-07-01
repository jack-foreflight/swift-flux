//
//  Parallel.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@resultBuilder
public struct Parallel: ActionBuilder {
    public let actions: [any Action]
    public var body: some Action { Operation.parallel(actions) }

    public init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Parallel _ group: () -> Self) {
        self.actions = group().actions
    }
}
