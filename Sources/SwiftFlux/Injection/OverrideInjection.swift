//
//  OverrideInjection.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public protocol OverrideInjection: Injection {
    static var overrideValue: Value { get }
}

extension OverrideInjection {
    public static var defaultValue: Value { overrideValue }
}
