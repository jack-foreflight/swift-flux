//
//  FluxArchitectureMacrosPlugin.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FluxArchitectureMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AppStateMacro.self,
        StoreProvidingMacro.self,
    ]
}
