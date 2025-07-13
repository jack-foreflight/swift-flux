//
//  Selection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import Foundation

@MainActor
public protocol Selection: Sendable {
    associatedtype State
    func select() -> State
}
