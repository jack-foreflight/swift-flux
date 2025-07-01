//
//  LiveInjection.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

public protocol LiveInjection: Injection {
    static func live(container: Container) -> Value
}
