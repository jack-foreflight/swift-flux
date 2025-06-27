//
//  Syntax+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/19/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension VariableDeclSyntax {

}

extension AttributeSyntax {
    func extractTypeFromArguments() -> String? {
        guard let arguments,
            case let .argumentList(argList) = arguments,
            let firstArg = argList.first
        else {
            return nil
        }

        if let memberAccess = firstArg.expression.as(MemberAccessExprSyntax.self),
            memberAccess.declName.baseName.text == "self",
            let baseType = memberAccess.base?.as(DeclReferenceExprSyntax.self)
        {
            return baseType.baseName.text
        } else if let declRef = firstArg.expression.as(DeclReferenceExprSyntax.self) {
            return declRef.baseName.text
        } else {
            return nil
        }
    }
}
