//
//  AppEnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

public protocol AppEnvironmentKey {
    typealias Container = AppEnvironmentValues
    associatedtype Value
    static func build(container: Container) -> Value
}
