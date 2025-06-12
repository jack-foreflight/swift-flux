//
//  AppState.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

/// A protocol that represents application state in the Flux architecture.
/// Classes conforming to this protocol can be managed by a Store and automatically
/// register nested AppState properties.
public protocol AppState {
    /// Registers this state and any nested AppState properties with the given registrar.
    /// - Parameter registrable: The registrar to register state objects with
    @MainActor func register(with registrable: some Registrable)
}

/// A macro that automatically implements AppState conformance and Observable behavior.
/// This macro generates the necessary observation infrastructure and automatic registration
/// of nested AppState properties.
@attached(memberAttribute)
@attached(member, names: named(_$observationRegistrar), named(access), named(withMutation))
@attached(extension, conformances: AppState, Observable, names: named(register))
public macro AppState() = #externalMacro(module: "SwiftFluxMacros", type: "AppStateMacro")
