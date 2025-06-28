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

    var awaitable: Bool { if case .async = self { true } else { false } }
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

/// Group action that executes actions sequentially in order
@resultBuilder
public struct Sequential: Action {
    let actions: [any Action]
    public var body: some Action { Operation.sequential(actions) }

    private init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Sequential _ group: () -> Self) {
        self.actions = group().actions
    }

    public static func buildBlock(_ components: (any Action)...) -> [any Action] {
        components
    }

    public static func buildOptional(_ component: [any Action]?) -> [any Action] {
        component ?? []
    }

    public static func buildEither(first component: [any Action]) -> [any Action] {
        component
    }

    public static func buildEither(second component: [any Action]) -> [any Action] {
        component
    }

    public static func buildPartialBlock(first: [any Action]) -> [any Action] {
        first
    }

    public static func buildPartialBlock(accumulated: [any Action], next: [any Action]) -> [any Action] {
        accumulated + next
    }

    public static func buildExpression(_ expression: some Action) -> [any Action] {
        [expression]
    }

    public static func buildExpression(_ expression: Sequential...) -> [any Action] {
        expression.flatMap { $0.actions }
    }

    public static func buildArray(_ components: [[any Action]]) -> [any Action] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any Action]) -> [any Action] {
        component
    }

    public static func buildFinalResult(_ component: [any Action]) -> Sequential {
        Sequential(component)
    }
}

/// Group action that executes actions concurrently in parallel
@resultBuilder
public struct Parallel: Action {
    let actions: [any Action]
    public var body: some Action { Operation.parallel(actions) }

    private init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@Parallel _ group: () -> Self) {
        self.actions = group().actions
    }

    public static func buildBlock(_ components: (any Action)...) -> [any Action] {
        components
    }

    public static func buildOptional(_ component: [any Action]?) -> [any Action] {
        component ?? []
    }

    public static func buildEither(first component: [any Action]) -> [any Action] {
        component
    }

    public static func buildEither(second component: [any Action]) -> [any Action] {
        component
    }

    public static func buildPartialBlock(first: [any Action]) -> [any Action] {
        first
    }

    public static func buildPartialBlock(accumulated: [any Action], next: [any Action]) -> [any Action] {
        accumulated + next
    }

    public static func buildExpression(_ expression: some Action) -> [any Action] {
        [expression]
    }

    public static func buildExpression(_ expression: Parallel...) -> [any Action] {
        expression.flatMap { $0.actions }
    }

    public static func buildArray(_ components: [[any Action]]) -> [any Action] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any Action]) -> [any Action] {
        component
    }

    public static func buildFinalResult(_ component: [any Action]) -> Parallel {
        Parallel(component)
    }
}

public struct EnvironmentAction<Body: Action>: Action {
    let environment: AppEnvironmentValues
    let build: () -> Body

    init(store: Store, build: @escaping () -> Body) {
        self.environment = withStore(store) { AppEnvironmentValues.current }
        self.build = { withStore(store) { build() } }
    }

    init(state: some SharedState, build: @escaping () -> Body) {
        self.environment = withState(state) { AppEnvironmentValues.current }
        self.build = { withState(state) { build() } }
    }

    init<Value>(
        keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
        value: Value,
        build: @escaping () -> Body
    ) {
        self.environment = withEnvironment(keyPath, value: value) { AppEnvironmentValues.current }
        self.build = { withEnvironment(keyPath, value: value) { build() } }
    }

    init<Key: AppEnvironmentKey>(
        key: Key.Type,
        value: Key.Value,
        build: @escaping () -> Body
    ) {
        self.environment = withEnvironment(key, value: value) { AppEnvironmentValues.current }
        self.build = { withEnvironment(key, value: value) { build() } }
    }

    public var body: some Action { Operation.environment(environment, build()) }
}

// MARK: Extensions

extension Operation {
    @MainActor public func execute() throws {
        guard case .sync(let operation) = self else { return }
        try operation()
    }

    @MainActor public func execute() async throws {
        switch self {
        case .sync(let operation): try operation()
        case .async(let operation): try await operation()
        default: break
        }
    }
}

extension [Operation] {
    @MainActor var awaitable: Bool { contains { $0.awaitable } }

    @MainActor public func executeAll() throws {
        for element in self { try element.execute() }
    }

    @MainActor public func executeAll() async throws {
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

extension Action {
    public func environment(_ store: Store) -> some Action {
        EnvironmentAction(store: store) { self }
    }

    public func environment(_ state: some SharedState) -> some Action {
        EnvironmentAction(state: state) { self }
    }

    public func environment<Value>(
        _ keyPath: WritableKeyPath<AppEnvironmentValues, Value>,
        _ value: Value
    ) -> some Action {
        EnvironmentAction(keyPath: keyPath, value: value) { self }
    }

    public func environment<Key: AppEnvironmentKey>(
        _ key: Key.Type,
        _ value: Key.Value
    ) -> some Action {
        EnvironmentAction(key: key, value: value) { self }
    }
}
