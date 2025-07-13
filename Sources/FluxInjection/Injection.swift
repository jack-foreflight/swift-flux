//
//  Injection.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/19/25.
//

import Foundation

public protocol Injection: Sendable {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
}
