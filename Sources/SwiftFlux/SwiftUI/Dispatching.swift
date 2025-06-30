//
//  Dispatching.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Dispatching {
    var store: Store { get }
}

extension Dispatching {
    public func dispatch(_ action: some Action) {
        store.dispatch(action)
    }
}
