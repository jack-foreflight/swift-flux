//
//  Injection+Override.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Injection {
    public static var overrideOrDefault: Value {
        (Self.self as? any OverrideInjection.Type)?.overrideValue as? Value ?? defaultValue
    }
}
