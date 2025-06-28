//
//  ActionBuilder.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

@resultBuilder
public protocol ActionBuilder: Action {
    var actions: [any Action] { get }
    init(_ actions: [any Action])
}

extension ActionBuilder {
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

    public static func buildFinalResult(_ component: [any Action]) -> Self {
        Self(component)
    }
}

@resultBuilder
public struct ActionGroup<Builder: ActionBuilder>: ActionBuilder {
    public let actions: [any Action]

    public init(_ actions: [any Action]) {
        self.actions = actions
    }

    public init(@ActionGroup<Builder> _ group: () -> Self) {
        self.actions = group().actions
    }

    public var body: some Action {
        switch Builder.self {
        case is Sequential.Type: Operation.sequential(actions)
        case is Parallel.Type: Operation.parallel(actions)
        default: Operation.sequential(actions)
        }
    }
}

/// Group action that executes actions sequentially in order
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

/// Group action that executes actions concurrently in parallel
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
