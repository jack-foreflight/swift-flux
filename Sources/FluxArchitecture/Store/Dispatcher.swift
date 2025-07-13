//
//  Dispatcher.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Dispatcher: Sendable {
    var store: Store { get }
}

extension Dispatcher {
    public func dispatch(_ action: some Action) {
        store.dispatch(action)
    }
}
