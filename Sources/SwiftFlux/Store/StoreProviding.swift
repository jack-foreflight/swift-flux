//
//  StoreProviding.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
public protocol StoreProviding: Selector, Dispatcher, Binder {}

/// A macro that automatically implements AppState conformance and Observable behavior.
/// This macro generates the necessary observation infrastructure and automatic registration
/// of nested AppState properties.
@attached(member, names: named(store))
@attached(extension, conformances: StoreProviding)
public macro StoreProviding() = #externalMacro(module: "SwiftFluxMacros", type: "StoreProvidingMacro")
