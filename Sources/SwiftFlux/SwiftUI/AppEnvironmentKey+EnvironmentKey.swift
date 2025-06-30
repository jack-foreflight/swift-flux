//
//  AppEnvironmentKey+EnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import SwiftUI

extension AppEnvironmentKey where Self: SwiftUI.EnvironmentKey {
    public static func build(container: Container) -> Value { Self.defaultValue }
}
