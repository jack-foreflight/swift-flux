//
//  SharedState.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol SharedState: AnyObject, Sendable {
    @MainActor func register(in store: Store)
}
