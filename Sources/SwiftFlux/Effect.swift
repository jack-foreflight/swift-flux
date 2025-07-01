//
//  Effect.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

@MainActor
public protocol Effect {
    associatedtype Event: SwiftFlux.Event
    associatedtype Body: SwiftFlux.Action

    var event: Event { get }
    var body: Body { get }
}
