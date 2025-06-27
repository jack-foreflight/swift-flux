//
//  AppEnvironmentValueMacro.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum AppEnvironmentValueMacro {
    static let name = "AppEnvironmentValue"
}

extension AppEnvironmentValueMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract the target protocol type from the macro arguments
        let protocolType = try extractProtocolType(from: node)

        // Get the concrete type name from the declaration
        guard let structDecl = declaration.as(StructDeclSyntax.self),
            let typeName = structDecl.name.text.nilIfEmpty
        else {
            throw AppEnvironmentValueError.unsupportedDeclaration
        }

        let actualProtocolType = protocolType == "Self" ? typeName : protocolType

        // Analyze initializers to determine resolution strategy
        let initAnalysis = try analyzeInitializers(in: structDecl)

        // Generate the AppEnvironmentKey conformance with smart initialization
        let conformance: DeclSyntax = """
            public static let defaultValue: \(raw: actualProtocolType) = \(raw: initAnalysis.initializationCode)
            """

        return [conformance]
    }

    private static func extractProtocolType(from node: AttributeSyntax) throws -> String {
        // If no arguments provided, use the concrete type itself
        guard let arguments = node.arguments,
            case let .argumentList(argList) = arguments,
            let firstArg = argList.first
        else {
            return "Self"
        }

        // Extract the protocol type from the argument - handle Type.self pattern
        if let memberAccess = firstArg.expression.as(MemberAccessExprSyntax.self),
            memberAccess.declName.baseName.text == "self",
            let baseType = memberAccess.base?.as(DeclReferenceExprSyntax.self)
        {
            return baseType.baseName.text
        } else if let declRef = firstArg.expression.as(DeclReferenceExprSyntax.self) {
            return declRef.baseName.text
        } else {
            throw AppEnvironmentValueError.invalidProtocolType
        }
    }
}

extension AppEnvironmentValueMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extract the protocol type from macro arguments
        let protocolType = try extractProtocolType(from: node)

        let actualProtocolType = protocolType == "Self" ? type.trimmedDescription : protocolType

        // Generate AppEnvironmentKey conformance extension
        let keyConformance = try ExtensionDeclSyntax(
            """
            extension \(type): SwiftFlux.AppEnvironmentKey {
                public typealias Value = \(raw: actualProtocolType)
            }
            """
        )

        // Generate AppEnvironmentValues convenience extension
        //        let valuesExtension = try generateEnvironmentValuesExtension(
        //            for: type,
        //            protocolType: protocolType
        //        )

        return [keyConformance]
    }

    private static func generateEnvironmentValuesExtension(
        for type: some TypeSyntaxProtocol,
        protocolType: String
    ) throws -> ExtensionDeclSyntax {
        let propertyName = camelCase(from: type.trimmedDescription)
        let actualProtocolType = protocolType == "Self" ? type.trimmedDescription : protocolType

        return try ExtensionDeclSyntax(
            """
            extension AppEnvironmentValues {
                public var \(raw: propertyName): \(raw: actualProtocolType) {
                    get { self[\(type).self] }
                    set { self[\(type).self] = newValue }
                }
            }
            """
        )
    }

    private static func camelCase(from typeName: String) -> String {
        guard let firstChar = typeName.first else { return typeName }
        return firstChar.lowercased() + typeName.dropFirst()
    }

    // MARK: - Initializer Analysis

    private static func analyzeInitializers(in structDecl: StructDeclSyntax) throws -> InitializerAnalysis {
        let typeName = structDecl.name.text
        let initializers = structDecl.memberBlock.members.compactMap { member in
            member.decl.as(InitializerDeclSyntax.self)
        }

        // Find the best initializer to use for default value
        if initializers.contains(where: { $0.signature.parameterClause.parameters.isEmpty }) {
            // No-argument initializer - simple case
            return InitializerAnalysis(
                initializationCode: "\(typeName)()",
                dependencies: [],
                isResolvable: true
            )
        }

        // Find initializer with all resolvable parameters
        for initializer in initializers {
            let analysis = try analyzeInitializerParameters(initializer, typeName: typeName)
            if analysis.isResolvable {
                return analysis
            }
        }

        // No resolvable initializer found
        throw AppEnvironmentValueError.noResolvableInitializer(typeName)
    }

    private static func analyzeInitializerParameters(
        _ initializer: InitializerDeclSyntax,
        typeName: String
    ) throws -> InitializerAnalysis {
        let parameters = initializer.signature.parameterClause.parameters
        var dependencies: [String] = []
        var initArguments: [String] = []

        for parameter in parameters {
            let paramName = parameter.firstName.text
            let paramType = parameter.type.trimmedDescription

            // Check if parameter has default value
            if parameter.defaultValue != nil {
                // Parameter has default - can omit from initialization
                continue
            }

            // Check if parameter type is a known environment value
            if isEnvironmentResolvableType(paramType) {
                dependencies.append(paramType)
                initArguments.append("\(paramName): \(paramType).defaultValue")
            } else {
                // Parameter cannot be resolved
                return InitializerAnalysis(
                    initializationCode: "",
                    dependencies: dependencies,
                    isResolvable: false
                )
            }
        }

        let initCode =
            initArguments.isEmpty
            ? "\(typeName)()"
            : "\(typeName)(\(initArguments.joined(separator: ", ")))"

        return InitializerAnalysis(
            initializationCode: initCode,
            dependencies: dependencies,
            isResolvable: true
        )
    }

    private static func isEnvironmentResolvableType(_ typeName: String) -> Bool {
        // This is a simplified version - in practice, we'd want to build
        // a registry of known environment types or check conformance
        let knownEnvironmentTypes = [
            "Logger", "APIClient", "APIService", "NetworkService", "UserService",
            "Store", "AppState",
        ]
        return knownEnvironmentTypes.contains(typeName)
    }
}

// MARK: - Data Types

struct InitializerAnalysis {
    let initializationCode: String
    let dependencies: [String]
    let isResolvable: Bool
}

// MARK: - Error Types

enum AppEnvironmentValueError: Error, CustomStringConvertible {
    case unsupportedDeclaration
    case invalidProtocolType
    case missingTypeName
    case noResolvableInitializer(String)

    var description: String {
        switch self {
        case .unsupportedDeclaration:
            return "@AppEnvironmentValue can only be applied to struct declarations"
        case .invalidProtocolType:
            return "@AppEnvironmentValue requires a valid protocol type argument"
        case .missingTypeName:
            return "@AppEnvironmentValue requires a named type declaration"
        case .noResolvableInitializer(let typeName):
            return "@AppEnvironmentValue: \(typeName) has no initializer that can be resolved from environment values or default parameters"
        }
    }
}

// MARK: - String Extensions

extension String {
    fileprivate var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

extension TokenSyntax {
    fileprivate var text: String {
        self.trimmedDescription
    }
}
