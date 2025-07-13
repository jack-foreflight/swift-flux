//
//  Action+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Action {
    public func dispatch() {
        @Injected(Store.self) var store
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
                        try await withThrowingTaskGroup { group in
                            for operation in operations {
                                group.addTask { try await operation.execute() }
                            }
                            try await group.waitForAll()
                        }
//                        try await withThrowingDiscardingTaskGroup { group in
//                            for operation in operations {
//                                group.addTask { try await operation.execute() }
//                            }
//                        }
                    }
                ]
            } else {
                return operations
            }
        case .environment(let environment, let action):
            return withInjection(environment) {
                action.flattened.compactMap {
                    switch $0 {
                    case .sync(let operation):
                        return .sync { try withInjection(environment) { try operation() } }
                    case .async(let operation):
                        return .async { try await withInjection(environment) { try await operation() } }
                    default: return nil
                    }
                }
            }
        }
    }
}
