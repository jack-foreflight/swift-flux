//
//  Effect.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/23/25.
//

import Foundation

public protocol Effect<State> {
    associatedtype State: SharedState

    func willSet(state: State)
    func didSet(state: State)
}
