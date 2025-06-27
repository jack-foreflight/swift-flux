//
//  WithState.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

@discardableResult public func withState<State: SharedState, Result>(
    _ state: State,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () throws -> Result
) rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[State.self] = state
    return try AppEnvironmentValues.$current.withValue(operationScoped) {
        try operation()
    }
}

@discardableResult public func withState<State: SharedState, Result>(
    _ state: State,
    file: StaticString = #file,
    line: UInt = #line,
    operation: () async throws -> Result
) async rethrows -> Result {
    var operationScoped = AppEnvironmentValues.current
    operationScoped[State.self] = state
    return try await AppEnvironmentValues.$current.withValue(operationScoped) {
        try await operation()
    }
}
