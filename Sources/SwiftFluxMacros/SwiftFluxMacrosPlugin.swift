//
//  SwiftFluxMacrosPlugin.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftFluxPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AppStateMacro.self,
        AppEnvironmentMacro.self,
        AppEnvironmentValueMacro.self,
    ]
}

struct MacroError: Error, CustomStringConvertible {
    
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
