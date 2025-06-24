//
//  State.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol AppState {
    static var id: AnyHashable { get }
    @MainActor func register(with store: Store)
}

extension AppState {
    public static var id: AnyHashable { ObjectIdentifier(Self.self) }
}

@attached(memberAttribute)
@attached(member, names: named(_$observationRegistrar), named(access), named(withMutation))
@attached(extension, conformances: AppState, Observable, names: named(register))
public macro AppState() = #externalMacro(module: "SwiftFluxMacros", type: "AppStateMacro")
