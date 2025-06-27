//
//  AppEnvironment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/19/25.
//

import Foundation

@propertyWrapper
public struct AppEnvironment<Value> {
    let value: () -> Value

    public var wrappedValue: Value { value() }
}
