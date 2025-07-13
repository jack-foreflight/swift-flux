//
//  Async.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public struct Async: Action {
    let operation: () async throws -> Void
    public var body: some Action { Operation.async(operation) }

    public init(_ operation: @escaping () async throws -> Void) {
        self.operation = operation
    }
}
