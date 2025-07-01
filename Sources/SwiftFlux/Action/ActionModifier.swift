//
//  ActionModifier.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

@MainActor
public protocol ActionModifier: Sendable {
    associatedtype Builder: ActionBuilder
    associatedtype Body: Action
    typealias Content = ModifiedContent

    @ActionGroup<Builder> func body(content: Content<Builder>) -> Body
}

public struct ModifiedContent<Builder: ActionBuilder>: Action {
    public var body: ActionGroup<Builder>

    init(_ action: some Action) {
        self.body = ActionGroup<Builder> { action }
    }
}

public struct ModifiedAction<Modifier: ActionModifier>: Action {
    private let modifier: Modifier
    private let content: ModifiedContent<Modifier.Builder>

    init(content: ModifiedContent<Modifier.Builder>, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public var body: some Action {
        modifier.body(content: content)
    }
}

extension Action {
    public func modifier<Modifier: ActionModifier>(_ modifier: Modifier) -> some Action {
        ModifiedAction(content: ModifiedContent(self), modifier: modifier)
    }
}
