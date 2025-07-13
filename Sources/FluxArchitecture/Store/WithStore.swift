//
//  WithStore.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@discardableResult
public func withStore<Result>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped.register(store)
    return try InjectionValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult
public func withStore<Result: Sendable>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = InjectionValues.current
    operationScoped.register(store)
    return try await InjectionValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
