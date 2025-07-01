//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

@MainActor
public protocol Action: Sendable {
    associatedtype Body: Action
    var body: Body { get }
}
