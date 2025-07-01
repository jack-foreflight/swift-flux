//
//  Sequential.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@resultBuilder
public struct Sequential: ActionBuilder {
    public let actions: [any Action]
    public var body: some Action { Operation.sequential(actions) }

    public init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Sequential _ group: () -> Self) {
        self.actions = group().actions
    }
}
