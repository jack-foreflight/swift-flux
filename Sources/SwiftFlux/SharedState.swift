//
//  SharedState.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

public protocol SharedState: AnyObject, Sendable {
    @MainActor func register(in store: Store)
}

//
//@attached(memberAttribute)
//@attached(member, names: named(_$observationRegistrar), named(access), named(withMutation))
//@attached(extension, conformances: AppState, Observable, names: named(register))
//public macro AppState() = #externalMacro(module: "SwiftFluxMacros", type: "AppStateMacro")
