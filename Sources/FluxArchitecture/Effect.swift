//
//  Effect.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

@MainActor
public protocol Effect: Sendable {
    associatedtype Event: FluxArchitecture.Event
    associatedtype Body: FluxArchitecture.Action

    var event: Event { get }
    var body: Body { get }
}
