//
//  Effect.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

public protocol Effect {
    associatedtype Condition: SwiftFlux.Condition
    associatedtype Body: Action

    var condition: Condition { get }
    var body: Body { get }
}
