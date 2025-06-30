//
//  StateSelector.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol StateSelector<ViewState> {
    associatedtype ViewState
    func select(store: Store) -> ViewState
}
