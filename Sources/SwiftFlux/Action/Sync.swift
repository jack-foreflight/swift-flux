//
//  Sync.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public struct Sync: Action {
    let operation: () throws -> Void
    public var body: some Action { Operation.sync(operation) }

    public init(_ operation: @escaping () throws -> Void) {
        self.operation = operation
    }
}
