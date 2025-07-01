//
//  Selection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Selection<State> {
    associatedtype State
    func select(store: Store) -> State
}
