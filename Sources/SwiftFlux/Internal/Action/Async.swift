//
//  Async.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public struct Async: Action {
    @AppEnvironment(Store.self) private var store
    private let operation: () async throws -> Void

    public init(_ operation: @escaping () async throws -> Void) {
        self.operation = operation
    }

    public var body: Self { self }

    public func sync() {
        store.register { Task { await async() } }
    }

    public func async() async {
        do {
            try await operation()
        } catch {

        }
    }
}
