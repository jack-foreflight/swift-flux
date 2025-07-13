//
//  Diagnostics.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/13/25.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct ObservationDiagnostic: DiagnosticMessage {
    enum ID: String {
        case invalidApplication = "invalid type"
        case missingInitializer = "missing initializer"
        case missingBody = "missing body"
    }

    var message: String
    var diagnosticID: MessageID
    var severity: DiagnosticSeverity

    init(message: String, diagnosticID: SwiftDiagnostics.MessageID, severity: SwiftDiagnostics.DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    init(message: String, domain: String, id: ID, severity: SwiftDiagnostics.DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: domain, id: id.rawValue)
        self.severity = severity
    }
}

extension DiagnosticsError {
    init<S: SyntaxProtocol>(syntax: S, message: String, domain: String = "FluxObservation", id: ObservationDiagnostic.ID, severity: SwiftDiagnostics.DiagnosticSeverity = .error) {
        self.init(diagnostics: [
            Diagnostic(node: Syntax(syntax), message: ObservationDiagnostic(message: message, domain: domain, id: id, severity: severity))
        ])
    }
}
