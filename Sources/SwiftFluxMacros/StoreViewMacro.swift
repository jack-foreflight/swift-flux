//
//  AppView.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/30/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum StoreViewMacro: MemberMacro {
    private static let module = "SwiftFlux"

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self),
            structDecl.inheritanceClause?.inheritedTypes.contains(where: { $0.type.trimmedDescription == "View" }) == true
        else {
            throw MacroError("@StoreView can only be applied to structs conforming to View")
        }

        let store: DeclSyntax =
            """
            @Environment(\\.store) var store
            """
        return [store]
    }
}

extension StoreViewMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let selectingConformance = try ExtensionDeclSyntax("extension \(type): \(raw: module).Selecting {}")
        let dispatchingConformance = try ExtensionDeclSyntax("extension \(type): \(raw: module).Dispatching {}")
        return [selectingConformance, dispatchingConformance]
    }
}
