//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol Action<State, Failure> {
    associatedtype State: SwiftFlux.AppState
    associatedtype Failure = any Error

    static var id: AnyHashable { get }
    func precondition(state: State) -> Bool
    func body(state: State) throws
    func failed(error: Failure, state: State)
}

extension Action {
    public static var id: AnyHashable { ObjectIdentifier(Self.self) }
    public func precondition(state: State) -> Bool { true }
}

extension Action where Failure == Never {
    public func failed(error: Never, state: State) {}
}

public protocol AsyncAction<Failure> {
    associatedtype Failure = any Error

    static var id: AnyHashable { get }
    var behavior: AsyncBehavior { get }
    var priority: TaskPriority { get }
    func precondition(store: Store) async -> Bool
    func body(store: Store) async throws
    func failed(error: Failure, store: Store) async
}

public enum AsyncBehavior {
    case none
    case debounce(any DurationProtocol)
    case throttle(any DurationProtocol)
}

extension AsyncAction {
    public static var id: AnyHashable { ObjectIdentifier(Self.self) }
    public var behavior: AsyncBehavior { .none }
    public var priority: TaskPriority { .userInitiated }
    public func precondition(store: Store) async -> Bool { true }
}

extension AsyncAction where Failure == Never {
    public func failed(error: Never, store: Store) async {}
}

@resultBuilder
public struct ActionBuilder {
    public static func buildBlock(_ actions: any Action...) -> [any Action] {
        actions
    }

    public static func buildOptional(_ action: [any Action]?) -> [any Action] {
        action ?? []
    }

    public static func buildEither(first action: [any Action]) -> [any Action] {
        action
    }

    public static func buildEither(second action: [any Action]) -> [any Action] {
        action
    }

    public static func buildArray(_ actions: [[any Action]]) -> [any Action] {
        actions.flatMap { $0 }
    }

    public static func buildExpression(_ action: any Action) -> [any Action] {
        [action]
    }

    public static func buildExpression(_ actions: [any Action]) -> [any Action] {
        actions
    }
}

extension ActionBuilder {
    public static func buildBlock(_ actions: any AsyncAction...) -> [any AsyncAction] {
        actions
    }

    public static func buildOptional(_ action: [any AsyncAction]?) -> [any AsyncAction] {
        action ?? []
    }

    public static func buildEither(first action: [any AsyncAction]) -> [any AsyncAction] {
        action
    }

    public static func buildEither(second action: [any AsyncAction]) -> [any AsyncAction] {
        action
    }

    public static func buildArray(_ actions: [[any AsyncAction]]) -> [any AsyncAction] {
        actions.flatMap { $0 }
    }

    public static func buildExpression(_ action: any AsyncAction) -> [any AsyncAction] {
        [action]
    }

    public static func buildExpression(_ actions: [any AsyncAction]) -> [any AsyncAction] {
        actions
    }
}

public struct Mutate<State: AppState>: Action {
    private let body: (State) -> Void

    public init(_ body: @escaping (State) -> Void) {
        self.body = body
    }

    public func body(state: State) {
        body(state)
    }
}

public struct Concurrent: AsyncAction {
    private let actions: () -> [any AsyncAction]

    init(@ActionBuilder _ actions: @escaping () -> [any AsyncAction]) {
        self.actions = actions
    }

    public func body(store: Store) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for action in actions() {
                group.addTask { try await action.body(store: store) }
            }
            try await group.waitForAll()
        }
    }
}

public struct Sequential: AsyncAction {
    private let actions: () -> [any AsyncAction]

    init(@ActionBuilder _ actions: @escaping () -> [any AsyncAction]) {
        self.actions = actions
    }

    public func body(store: Store) async throws {
        for action in actions() {
            try await action.body(store: store)
        }
    }
}
