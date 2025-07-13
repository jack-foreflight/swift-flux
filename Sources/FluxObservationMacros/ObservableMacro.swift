//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableMacro {
    static let moduleName = "FluxObservation"

    static let conformanceName = "Observable"
    static var qualifiedConformanceName: String {
        "\(moduleName).\(conformanceName)"
    }

    static var observableConformanceType: TypeSyntax {
        "\(raw: qualifiedConformanceName)"
    }

    static let registrarTypeName = "ObservationRegistrar"
    static var qualifiedRegistrarTypeName: String {
        "\(moduleName).\(registrarTypeName)"
    }

    static let trackedMacroName = "ObservationTracked"
    static let ignoredMacroName = "ObservationIgnored"

    static let registrarVariableName = "_$observationRegistrar"

    static func registrarVariable(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {

        """
        @\(raw: ignoredMacroName) private let \(raw: registrarVariableName) = \(raw: qualifiedRegistrarTypeName)()
        """
    }

    static func accessFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        return
            """
            internal func access<\(memberGeneric)>(
              keyPath: KeyPath<\(observableType), \(memberGeneric)>
            ) {
              \(raw: registrarVariableName).access(self, keyPath: keyPath)
            }
            """
    }

    static func withMutationFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        let mutationGeneric = context.makeUniqueName("MutationResult")
        return
            """
            internal func withMutation<\(memberGeneric), \(mutationGeneric)>(
              keyPath: KeyPath<\(observableType), \(memberGeneric)>,
              _ mutation: () throws -> \(mutationGeneric)
            ) rethrows -> \(mutationGeneric) {
              try \(raw: registrarVariableName).withMutation(of: self, keyPath: keyPath, mutation)
            }
            """
    }

    static func shouldNotifyObserversNonEquatableFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        return
            """
             private func shouldNotifyObservers<\(memberGeneric)>(_ lhs: \(memberGeneric), _ rhs: \(memberGeneric)) -> Bool { true }
            """
    }

    static func shouldNotifyObserversEquatableFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        return
            """
            private func shouldNotifyObservers<\(memberGeneric): Equatable>(_ lhs: \(memberGeneric), _ rhs: \(memberGeneric)) -> Bool { lhs != rhs }
            """
    }

    static func shouldNotifyObserversNonEquatableObjectFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        return
            """
             private func shouldNotifyObservers<\(memberGeneric): AnyObject>(_ lhs: \(memberGeneric), _ rhs: \(memberGeneric)) -> Bool { lhs !== rhs }
            """
    }

    static func shouldNotifyObserversEquatableObjectFunction(_ observableType: TokenSyntax, context: some MacroExpansionContext) -> DeclSyntax {
        let memberGeneric = context.makeUniqueName("Member")
        return
            """
            private func shouldNotifyObservers<\(memberGeneric): Equatable & AnyObject>(_ lhs: \(memberGeneric), _ rhs: \(memberGeneric)) -> Bool { lhs != rhs }
            """
    }

    static var ignoredAttribute: AttributeSyntax {
        AttributeSyntax(
            leadingTrivia: .space,
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier(ignoredMacroName)),
            trailingTrivia: .space
        )
    }

    static var trackedAttribute: AttributeSyntax {
        AttributeSyntax(
            leadingTrivia: .space,
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier(trackedMacroName)),
            trailingTrivia: .space
        )
    }
}

extension ObservableMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        conformingTo protocols: [TypeSyntax],
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let identified = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        let observableType = identified.name.trimmed

        if declaration.isEnum {
            // enumerations cannot store properties
            throw DiagnosticsError(syntax: node, message: "'@Observable' cannot be applied to enumeration type '\(observableType.text)'", id: .invalidApplication)
        }
        if declaration.isStruct {
            // structs are not yet supported; copying/mutation semantics tbd
            throw DiagnosticsError(syntax: node, message: "'@Observable' cannot be applied to struct type '\(observableType.text)'", id: .invalidApplication)
        }
        if declaration.isActor {
            // actors cannot yet be supported for their isolation
            throw DiagnosticsError(syntax: node, message: "'@Observable' cannot be applied to actor type '\(observableType.text)'", id: .invalidApplication)
        }

        var declarations = [DeclSyntax]()

        declaration.addIfNeeded(ObservableMacro.registrarVariable(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.accessFunction(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.withMutationFunction(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.shouldNotifyObserversNonEquatableFunction(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.shouldNotifyObserversEquatableFunction(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.shouldNotifyObserversNonEquatableObjectFunction(observableType, context: context), to: &declarations)
        declaration.addIfNeeded(ObservableMacro.shouldNotifyObserversEquatableObjectFunction(observableType, context: context), to: &declarations)

        return declarations
    }
}

extension ObservableMacro: MemberAttributeMacro {
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
        guard let property = member.as(VariableDeclSyntax.self), property.isValidForObservation,
            property.identifier != nil
        else {
            return []
        }

        // dont apply to ignored properties or properties that are already flagged as tracked
        if property.hasMacroApplication(ObservableMacro.ignoredMacroName) || property.hasMacroApplication(ObservableMacro.trackedMacroName) {
            return []
        }

        return [
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier(ObservableMacro.trackedMacroName)))
        ]
    }
}

extension ObservableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // This method can be called twice - first with an empty `protocols` when
        // no conformance is needed, and second with a `MissingTypeSyntax` instance.
        if protocols.isEmpty {
            return []
        }

        let decl: DeclSyntax = """
            extension \(raw: type.trimmedDescription): \(raw: qualifiedConformanceName) {}
            """
        let ext = decl.cast(ExtensionDeclSyntax.self)

        if let availability = declaration.attributes.availability {
            return [ext.with(\.attributes, availability)]
        } else {
            return [ext]
        }
    }
}

public struct ObservationTrackedMacro: AccessorMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: Declaration,
        in context: Context
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
            property.isValidForObservation,
            let identifier = property.identifier?.trimmed
        else {
            return []
        }

        guard context.lexicalContext[0].as(ClassDeclSyntax.self) != nil else {
            return []
        }

        if property.hasMacroApplication(ObservableMacro.ignoredMacroName) {
            return []
        }

        let initAccessor: AccessorDeclSyntax =
            """
            @storageRestrictions(initializes: _\(identifier))
            init(initialValue) {
              _\(identifier) = initialValue
            }
            """
        let getAccessor: AccessorDeclSyntax =
            """
            get {
              access(keyPath: \\.\(identifier))
              return _\(identifier)
            }
            """

        // the guard else case must include the assignment else
        // cases that would notify then drop the side effects of `didSet` etc
        let setAccessor: AccessorDeclSyntax =
            """
            set {
              guard shouldNotifyObservers(_\(identifier), newValue) else {
                _\(identifier) = newValue
                return
              }
              withMutation(keyPath: \\.\(identifier)) {
                _\(identifier) = newValue
              }
            }
            """

        // Note: this accessor cannot test the equality since it would incur
        // additional CoW's on structural types. Most mutations in-place do
        // not leave the value equal so this is "fine"-ish.
        // Warning to future maintence: adding equality checks here can make
        // container mutation O(N) instead of O(1).
        // e.g. observable.array.append(element) should just emit a change
        // to the new array, and NOT cause a copy of each element of the
        // array to an entirely new array.
        let modifyAccessor: AccessorDeclSyntax =
            """
            _modify {
              access(keyPath: \\.\(identifier))
              \(raw: ObservableMacro.registrarVariableName).willSet(self, keyPath: \\.\(identifier))
              defer { \(raw: ObservableMacro.registrarVariableName).didSet(self, keyPath: \\.\(identifier)) }
              yield &_\(identifier)
            }
            """

        return [initAccessor, getAccessor, setAccessor, modifyAccessor]
    }
}

extension ObservationTrackedMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
            property.isValidForObservation,
            property.identifier?.trimmed != nil
        else {
            return []
        }

        guard context.lexicalContext[0].as(ClassDeclSyntax.self) != nil else {
            return []
        }

        if property.hasMacroApplication(ObservableMacro.ignoredMacroName) {
            return []
        }

        let localContext = FluxLocalMacroExpansionContext(context: context)
        let storage = DeclSyntax(property.privatePrefixed("_", addingAttribute: ObservableMacro.ignoredAttribute, removingAttribute: ObservableMacro.trackedAttribute, in: localContext))
        return [storage]
    }
}

public struct ObservationIgnoredMacro: AccessorMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: Declaration,
        in context: Context
    ) throws -> [AccessorDeclSyntax] {
        []
    }
}
