//
//  Operation.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

enum Operation: Action {
    case sync(() throws -> Void)
    case async(() async throws -> Void)
    case sequential([any Action])
    case parallel([any Action])
    case environment(InjectionValues, any Action)
    var body: some Action { self }
}

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
