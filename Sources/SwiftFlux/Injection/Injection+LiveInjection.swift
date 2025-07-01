//
//  Injection+LiveInjection.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Injection where Self: LiveInjection {
    public static func inject(container: Container) -> Value { live(container: container) }
}
