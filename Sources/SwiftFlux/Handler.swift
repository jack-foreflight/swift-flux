//
//  Handler.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/20/25.
//

import Foundation

public protocol Handler<Action> {
    associatedtype Action: SwiftFlux.Action

    func willPerform(action: Action)
    func didPerform(action: Action)
}

public protocol AsyncHandler<Action> {
    associatedtype Action: AsyncAction

    func willPerform(action: Action)
    func didPerform(action: Action)
}
