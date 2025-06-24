//
//  AppEnvironmentMacro.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/18/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum AppEnvironmentMacro {
    static let name = "AppEnvironment"
}

extension AppEnvironmentMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        guard let argument = node.arguments.first else {
            throw MacroError("Requires parameters")
        }
        if let keyPath = argument.expression.as(KeyPathExprSyntax.self) {
            return
                """
                AppEnvironmentValues.current[keyPath: \(raw: keyPath)]
                """
        } else if let type = argument.expression.as(DeclReferenceExprSyntax.self) {
            return
                """
                AppEnvironmentValues.current[\(raw: type).self]
                """
        }
        throw MacroError("Requires parameters")
    }
}
