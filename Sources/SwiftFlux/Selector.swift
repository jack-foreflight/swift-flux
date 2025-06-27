//
//  Selector.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol Selector<State> {
    associatedtype State
    func body(store: Store) -> State
}
