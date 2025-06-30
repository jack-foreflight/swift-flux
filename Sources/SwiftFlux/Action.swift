//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

@MainActor
public protocol Action: Sendable {
    associatedtype Body: Action
    var body: Body { get }
}

// MARK: Primitives
enum Operation: Action {
    case sync(() throws -> Void)
    case async(() async throws -> Void)
    case sequential([any Action])
    case parallel([any Action])
    case environment(AppEnvironmentValues, any Action)
    var body: some Action { self }
}

/// Primitive action that executes synchronously
public struct Sync: Action {
    let operation: () throws -> Void
    public var body: some Action { Operation.sync(operation) }

    public init(_ operation: @escaping () throws -> Void) {
        self.operation = operation
    }
}

/// Primitive action that executes asynchronously
public struct Async: Action {
    let operation: () async throws -> Void
    public var body: some Action { Operation.async(operation) }

    public init(_ operation: @escaping () async throws -> Void) {
        self.operation = operation
    }
}

// MARK: Extensions
extension Operation {
    var awaitable: Bool { if case .async = self { true } else { false } }

    public func execute() throws {
        guard case .sync(let operation) = self else { return }
        try operation()
    }

    public func execute() async throws {
        switch self {
        case .sync(let operation): try operation()
        case .async(let operation): try await operation()
        default: break
        }
    }
}

@MainActor
extension [Operation] {
    var awaitable: Bool { contains { $0.awaitable } }

    public func executeAll() throws {
        for element in self { try element.execute() }
    }

    public func executeAll() async throws {
        for element in self {
            switch element {
            case .sync(let operation): try operation()
            case .async(let operation): try await operation()
            default: continue
            }
        }
    }
}

extension Action {
    public func dispatch() {
        @AppEnvironment(Store.self) var store
        store.dispatch(self)
    }

    public func executeFlattened() throws {
        try flattened.executeAll()
    }

    public func executeFlattened() async throws {
        try await flattened.executeAll()
    }

    @inline(__always)
    var flattened: [Operation] {
        guard let operation = self as? Operation else { return body.flattened }
        switch operation {
        case .sync, .async: return [operation]
        case .sequential(let actions): return actions.flatMap { $0.flattened }
        case .parallel(let actions):
            let operations = actions.flatMap { $0.flattened }
            if operations.awaitable {
                return [
                    .async {
                        try await withThrowingDiscardingTaskGroup { group in
                            for operation in operations {
                                group.addTask { try await operation.execute() }
                            }
                        }
                    }
                ]
            } else {
                return operations
            }
        case .environment(let environment, let action):
            return withEnvironment(environment) {
                action.flattened.compactMap {
                    switch $0 {
                    case .sync(let operation):
                        return .sync { try withEnvironment(environment) { try operation() } }
                    case .async(let operation):
                        return .async { try await withEnvironment(environment) { try await operation() } }
                    default: return nil
                    }
                }
            }
        }
    }
}
