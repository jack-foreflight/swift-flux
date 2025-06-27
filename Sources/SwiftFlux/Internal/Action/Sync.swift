//
//  Sync.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public struct Sync: Action {
    private let operation: () throws -> Void

    public init(_ operation: @escaping () throws -> Void) {
        self.operation = operation
    }

    public var body: Self { self }

    public func sync() {
        do {
            try operation()
        } catch {

        }
    }

    public func async() async { sync() }
}
