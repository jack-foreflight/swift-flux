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

extension Syntax {
    var isNonGeneric: Bool {
        if let classDecl = self.as(ClassDeclSyntax.self) {
            if classDecl.genericParameterClause == nil { return true }
        } else if let structDecl = self.as(StructDeclSyntax.self) {
            if structDecl.genericParameterClause == nil { return true }
        } else if let enumDecl = self.as(EnumDeclSyntax.self) {
            if enumDecl.genericParameterClause == nil { return true }
        } else if let actorDecl = self.as(ActorDeclSyntax.self) {
            if actorDecl.genericParameterClause == nil { return true }
        }
        return false
    }
}

extension VariableDeclSyntax {
    var identifierPattern: IdentifierPatternSyntax? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)
    }

    var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }
        return true
    }

    var identifier: TokenSyntax? {
        identifierPattern?.identifier
    }

    var type: TypeSyntax? {
        bindings.first?.typeAnnotation?.type
    }

    func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
        let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding in
            switch patternBinding.accessorBlock?.accessors {
            case .accessors(let accessors):
                return accessors
            default:
                return nil
            }
        }.flatMap { $0 }
        return accessors.compactMap { accessor in
            if predicate(accessor.accessorSpecifier.tokenKind) {
                return accessor
            } else {
                return nil
            }
        }
    }

    var willSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.willSet) }
    }
    var didSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.didSet) }
    }

    var isComputed: Bool {
        if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
            return true
        } else {
            return bindings.contains { binding in
                if case .getter = binding.accessorBlock?.accessors {
                    return true
                } else {
                    return false
                }
            }
        }
    }

    var isImmutable: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    func isEquivalent(to other: VariableDeclSyntax) -> Bool {
        if isInstance != other.isInstance {
            return false
        }
        return identifier?.text == other.identifier?.text
    }

    var initializer: InitializerClauseSyntax? {
        bindings.first?.initializer
    }

    func hasMacroApplication(_ name: String) -> Bool {
        for attribute in attributes {
            switch attribute {
            case .attribute(let attr):
                if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)] {
                    return true
                }
            default:
                break
            }
        }
        return false
    }
}

extension TypeSyntax {
    var identifier: String? {
        for token in tokens(viewMode: .all) {
            switch token.tokenKind {
            case .identifier(let identifier):
                return identifier
            default:
                break
            }
        }
        return nil
    }

    func genericSubstitution(_ parameters: GenericParameterListSyntax?) -> String? {
        var genericParameters = [String: TypeSyntax?]()
        if let parameters {
            for parameter in parameters {
                genericParameters[parameter.name.text] = parameter.inheritedType
            }
        }
        var iterator = self.asProtocol(TypeSyntaxProtocol.self).tokens(viewMode: .sourceAccurate).makeIterator()
        guard let base = iterator.next() else {
            return nil
        }

        if let genericBase = genericParameters[base.text] {
            if let text = genericBase?.identifier {
                return "some " + text
            } else {
                return nil
            }
        }
        var substituted = base.text

        while let token = iterator.next() {
            switch token.tokenKind {
            case .leftAngle:
                substituted += "<"
            case .rightAngle:
                substituted += ">"
            case .comma:
                substituted += ","
            case .identifier(let identifier):
                let type: TypeSyntax = "\(raw: identifier)"
                guard let substituedType = type.genericSubstitution(parameters) else {
                    return nil
                }
                substituted += substituedType
                break
            default:
                // ignore?
                break
            }
        }

        return substituted
    }
}

extension FunctionDeclSyntax {
    var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }
        return true
    }

    struct SignatureStandin: Equatable {
        var isInstance: Bool
        var identifier: String
        var parameters: [String]
        var returnType: String
    }

    var signatureStandin: SignatureStandin {
        var parameters = [String]()
        for parameter in signature.parameterClause.parameters {
            parameters.append(parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? ""))
        }
        let returnType = signature.returnClause?.type.genericSubstitution(genericParameterClause?.parameters) ?? "Void"
        return SignatureStandin(isInstance: isInstance, identifier: name.text, parameters: parameters, returnType: returnType)
    }

    func isEquivalent(to other: FunctionDeclSyntax) -> Bool {
        signatureStandin == other.signatureStandin
    }
}

extension DeclGroupSyntax {
    var memberFunctionStandins: [FunctionDeclSyntax.SignatureStandin] {
        var standins = [FunctionDeclSyntax.SignatureStandin]()
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                standins.append(function.signatureStandin)
            }
        }
        return standins
    }

    func hasMemberFunction(equvalentTo other: FunctionDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                if function.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }

    func hasMemberProperty(equivalentTo other: VariableDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self) {
                if variable.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }

    var definedVariables: [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                return variableDecl
            }
            return nil
        }
    }

    func addIfNeeded(_ decl: DeclSyntax?, to declarations: inout [DeclSyntax]) {
        guard let decl else { return }
        if let fn = decl.as(FunctionDeclSyntax.self) {
            if !hasMemberFunction(equvalentTo: fn) {
                declarations.append(decl)
            }
        } else if let property = decl.as(VariableDeclSyntax.self) {
            if !hasMemberProperty(equivalentTo: property) {
                declarations.append(decl)
            }
        }
    }

    var isClass: Bool {
        self.is(ClassDeclSyntax.self)
    }

    var isActor: Bool {
        self.is(ActorDeclSyntax.self)
    }

    var isEnum: Bool {
        self.is(EnumDeclSyntax.self)
    }

    var isStruct: Bool {
        self.is(StructDeclSyntax.self)
    }
}

struct FluxLocalMacroExpansionContext<Context: MacroExpansionContext> {
    var context: Context
}

extension DeclModifierListSyntax {
    func privatePrefixed(_ prefix: String, in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> DeclModifierListSyntax {
        let modifier: DeclModifierSyntax = DeclModifierSyntax(name: "private", trailingTrivia: .space)
        return [modifier]
            + filter {
                switch $0.name.tokenKind {
                case .keyword(let keyword):
                    switch keyword {
                    case .fileprivate, .private, .internal, .package, .public:
                        return false
                    default:
                        return true
                    }
                default:
                    return true
                }
            }
    }

    init(keyword: Keyword) {
        self.init([DeclModifierSyntax(name: .keyword(keyword))])
    }
}

extension TokenSyntax {
    func privatePrefixed(_ prefix: String, in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> TokenSyntax {
        switch tokenKind {
        case .identifier(let identifier):
            return TokenSyntax(.identifier(prefix + identifier), leadingTrivia: leadingTrivia, trailingTrivia: trailingTrivia, presence: presence)
        default:
            return self
        }
    }
}

extension CodeBlockSyntax {
    func locationAnnotated(in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> CodeBlockSyntax {
        guard let firstStatement = statements.first, let loc = context.context.location(of: firstStatement) else {
            return self
        }

        return CodeBlockSyntax(
            leadingTrivia: leadingTrivia,
            leftBrace: leftBrace,
            statements: CodeBlockItemListSyntax {
                "#sourceLocation(file: \(loc.file), line: \(loc.line))"
                statements
                "#sourceLocation()"
            },
            rightBrace: rightBrace,
            trailingTrivia: trailingTrivia
        )
    }
}

extension AccessorDeclSyntax {
    func locationAnnotated(in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> AccessorDeclSyntax {
        AccessorDeclSyntax(
            leadingTrivia: leadingTrivia,
            attributes: attributes,
            modifier: modifier,
            accessorSpecifier: accessorSpecifier,
            parameters: parameters,
            effectSpecifiers: effectSpecifiers,
            body: body?.locationAnnotated(in: context),
            trailingTrivia: trailingTrivia
        )
    }
}

extension AccessorBlockSyntax {
    func locationAnnotated(in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> AccessorBlockSyntax {
        switch accessors {
        case .accessors(let accessorList):
            let remapped = AccessorDeclListSyntax {
                accessorList.map { $0.locationAnnotated(in: context) }
            }
            return AccessorBlockSyntax(accessors: .accessors(remapped))
        case .getter(let codeBlockList):
            return AccessorBlockSyntax(accessors: .getter(codeBlockList))
        }
    }
}

extension PatternBindingListSyntax {
    func privatePrefixed(_ prefix: String, in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>) -> PatternBindingListSyntax {
        var bindings = self.map { $0 }
        for index in 0..<bindings.count {
            let binding = bindings[index]
            if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                bindings[index] = PatternBindingSyntax(
                    leadingTrivia: binding.leadingTrivia,
                    pattern: IdentifierPatternSyntax(
                        leadingTrivia: identifier.leadingTrivia,
                        identifier: identifier.identifier.privatePrefixed(prefix, in: context),
                        trailingTrivia: identifier.trailingTrivia
                    ),
                    typeAnnotation: binding.typeAnnotation,
                    initializer: binding.initializer,
                    accessorBlock: binding.accessorBlock?.locationAnnotated(in: context),
                    trailingComma: binding.trailingComma,
                    trailingTrivia: binding.trailingTrivia)

            }
        }

        return PatternBindingListSyntax(bindings)
    }
}

extension VariableDeclSyntax {
    func privatePrefixed(
        _ prefix: String, addingAttribute attribute: AttributeSyntax, removingAttribute toRemove: AttributeSyntax, in context: FluxLocalMacroExpansionContext<some MacroExpansionContext>
    )
        -> VariableDeclSyntax
    {
        let newAttributes =
            attributes.filter { attribute in
                switch attribute {
                case .attribute(let attr):
                    attr.attributeName.identifier != toRemove.attributeName.identifier
                default: true
                }
            } + [.attribute(attribute)]
        return VariableDeclSyntax(
            leadingTrivia: leadingTrivia,
            attributes: newAttributes,
            modifiers: modifiers.privatePrefixed(prefix, in: context),
            bindingSpecifier: TokenSyntax(bindingSpecifier.tokenKind, leadingTrivia: .space, trailingTrivia: .space, presence: .present),
            bindings: bindings.privatePrefixed(prefix, in: context),
            trailingTrivia: trailingTrivia
        )
    }

    var isValidForObservation: Bool {
        !isComputed && isInstance && !isImmutable && identifier != nil
    }
}
