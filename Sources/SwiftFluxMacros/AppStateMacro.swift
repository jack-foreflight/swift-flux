//
//  AppStateMacro.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AppStateMacro: MemberMacro {
    private static let module = "SwiftFlux"
    private static let observation = "Observation"
    private static let trackedAttributeName = "ObservationTracked"
    private static let ignoredAttributeName = "ObservationIgnored"

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let identifier = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        let className = IdentifierPatternSyntax(identifier: .init(stringLiteral: "\(identifier.name.trimmed)"))

        let registrar: DeclSyntax =
            """
            @\(raw: ignoredAttributeName) private let _$observationRegistrar = \(raw: observation).ObservationRegistrar()
            """
        let access: DeclSyntax =
            """
            internal nonisolated func access<Member>(
                keyPath: KeyPath<\(className), Member>
            ) {
                _$observationRegistrar.access(self, keyPath: keyPath)
            }
            """
        let withMutation: DeclSyntax =
            """
            internal nonisolated func withMutation<Member, MutationResult>(
                keyPath: KeyPath<\(className), Member>,
                _ mutation: () throws -> MutationResult
            ) rethrows -> MutationResult {
                try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
            }
            """
        return [
            registrar,
            access,
            withMutation,
        ]
    }
}

extension AppStateMacro: MemberAttributeMacro {

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {

        guard let variable = member.variable?.mutable?.instanced,
            let binding = variable.bindings.first
        else { return [] }

        if let accessors = binding.accessorBlock?.accessors {
            switch accessors {
            case let .accessors(accessorList):
                let specifiers = accessorList.lazy.map(\.accessorSpecifier.tokenKind)
                if !specifiers.contains(.keyword(.set)), !specifiers.contains(.keyword(._modify)) {
                    return []
                }
            case .getter:
                return []
            }
        }

        let currentAttributeNames = variable.attributes.compactMap {
            if case let .attribute(att) = $0 { att.attributeName.trimmedDescription } else { nil }
        }

        if currentAttributeNames.contains(ignoredAttributeName)
            || currentAttributeNames.contains(trackedAttributeName)
        {
            return []
        }

        let attributeName: TypeSyntax = "\(raw: "\(trackedAttributeName)")"
        return [AttributeSyntax(attributeName: attributeName)]
    }
}

extension AppStateMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError("@AppState can only be applied to classes")
        }

        let registrations = classDecl.memberBlock.members
            .compactMap { $0.decl.instanced?.identifiers }
            .flatMap { $0 }
            .compactMap { identifierPattern in
                "(\(identifierPattern.identifier.text) as? \(module).AppState)?.register(with: registrable)"
            }

        let stateConformance = try ExtensionDeclSyntax(
            """
            extension \(type): \(raw: module).AppState {
                public func register(with registrable: some \(raw: module).Registrable) {
                    registrable.register(state: self)
                    \(raw: registrations.joined(separator: "\n"))
                }
            }       
            """
        )
        let observableConformance = try ExtensionDeclSyntax("extension \(type): \(raw: observation).Observable { }")
        return [observableConformance, stateConformance]
    }
}

extension DeclSyntaxProtocol {
    var variable: VariableDeclSyntax? {
        self.as(VariableDeclSyntax.self)
    }

    var mutable: VariableDeclSyntax? {
        guard let variable else { return nil }
        guard variable.bindingSpecifier.tokenKind == .keyword(.var) else { return nil }
        return variable
    }

    var instanced: VariableDeclSyntax? {
        guard let variable else { return nil }
        let tokens = variable.modifiers.lazy.map(\.name.tokenKind)
        guard !tokens.contains(.keyword(.static)), !tokens.contains(.keyword(.class)) else { return nil }
        return variable
    }

    var identifiers: [IdentifierPatternSyntax]? {
        guard let variable else { return nil }
        return variable.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
    }
}
