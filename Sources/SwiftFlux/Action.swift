//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol Action {
    associatedtype Body: Action
    var body: Body { get }

    @MainActor func sync()
    @MainActor func async() async
}
