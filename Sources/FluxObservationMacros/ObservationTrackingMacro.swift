//
//  ObservationTrackingMacro.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/12/25.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ObservationTrackingMacro {
    static let moduleName = "FluxObservation"
}

extension ObservationTrackingMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        conformingTo protocols: [TypeSyntax],
        in context: Context
    ) throws -> [DeclSyntax] {
        // Validate that the macro is applied to a struct declaration
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw DiagnosticsError(syntax: node, message: "'@ObservationTracking' can only be applied to struct types", id: .invalidApplication)
        }

        // Check that the struct conforms to SwiftUI's View protocol
        let inheritsView =
            structDecl.inheritanceClause?.inheritedTypes.contains {
                if let identType = $0.type.as(IdentifierTypeSyntax.self) {
                    return identType.name.text == "View"
                }
                // Handle qualified types like SwiftUI.View as well
                if let memberType = $0.type.as(MemberTypeSyntax.self),
                    let baseType = memberType.baseType.as(IdentifierTypeSyntax.self),
                    baseType.name.text == "SwiftUI",
                    memberType.name.text == "View"
                {
                    return true
                }
                return false
            } ?? false
        guard inheritsView else {
            throw DiagnosticsError(syntax: node, message: "'@ObservationTracking' can only be applied to structs conforming to 'View'", id: .invalidApplication)
        }

        // Find the 'body' property in the struct's members
        let bodyVariable: VariableDeclSyntax? = structDecl.memberBlock.members.lazy
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                $0.bindings.first?
                    .pattern
                    .as(IdentifierPatternSyntax.self)?
                    .identifier.text == "body"
            }
            .first

        guard let bodyVariable else {
            throw DiagnosticsError(syntax: node, message: "Struct must have a `body` property to use '@ObservationTracking'", id: .missingBody)
        }

        // Ensure the 'body' property has an accessor block for computed body
        guard let declaration = bodyVariable.bindings.first?.accessorBlock?.accessors._syntaxNode else {
            throw DiagnosticsError(syntax: node, message: "Struct `body` property must have an accessor block to use '@ObservationTracking'", id: .missingBody)
        }

        // Construct the injected declarations: original body, container view, and traced body
        let syntax = DeclSyntax(
            """
            typealias Body = _ObservationTrackingBodyWrapper

            @ViewBuilder
            private var _nonTrackingBody: some View {
            \(raw: declaration.description)
            }

            @_implements(View, body)
            @inline(never)
            @ViewBuilder
            var _trackingBody: Self.Body {
                _ObservationTrackingBodyWrapper(wrappedView: self)
            }

            struct _ObservationTrackingBodyWrapper: View {
                @State private var observation: Int = 0
                let wrappedView: \(raw: structDecl.name.text)

                var body: some View {
                    let _ = observation
                    return withObservationTracking {
                        wrappedView._nonTrackingBody
                    } onChange: {
                        _observation.wrappedValue &+= 1
                    }
                }
            }
            """
        )

        return [syntax]
    }
}

extension ObservationTrackingMacro: MemberAttributeMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        MemberDeclaration: DeclSyntaxProtocol,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        attachedTo declaration: Declaration,
        providingAttributesFor member: MemberDeclaration,
        in context: Context
    ) throws -> [AttributeSyntax] {
        // Validate the member being treated is the body property
        guard let binding = member.as(VariableDeclSyntax.self)?.bindings.first else { return [] }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return [] }
        guard identifier.text == "body" else { return [] }

        // Apply the ViewBuilder result builder to the body property being overwritten
        return [
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("ViewBuilder")))
        ]
    }
}
