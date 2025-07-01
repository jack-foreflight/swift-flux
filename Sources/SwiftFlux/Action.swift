//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

@MainActor
public protocol Action {
    associatedtype Body: Action
    var body: Body { get }
}
