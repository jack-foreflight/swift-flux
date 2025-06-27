//
//  WithStore.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

@discardableResult public func withStore<Result>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[Store.self] = store
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withStore<Result>(
    _ store: Store,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[Store.self] = store
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
