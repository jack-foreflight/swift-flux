//
//  AppEnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public protocol AppEnvironmentKey {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
}
