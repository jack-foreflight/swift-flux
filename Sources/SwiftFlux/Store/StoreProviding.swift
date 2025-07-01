//
//  StoreProviding.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
public protocol StoreProviding: Selector, Dispatcher, Binder {}

@attached(member, names: named(store))
@attached(extension, conformances: StoreProviding)
public macro StoreProviding() = #externalMacro(module: "SwiftFluxMacros", type: "StoreProvidingMacro")
