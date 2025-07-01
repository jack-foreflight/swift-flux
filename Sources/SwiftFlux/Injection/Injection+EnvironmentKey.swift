//
//  Injection+EnvironmentKey.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import SwiftUI

extension Injection where Self: EnvironmentKey {
    public static func inject(container: Container) -> Value { Self.defaultValue }
}
