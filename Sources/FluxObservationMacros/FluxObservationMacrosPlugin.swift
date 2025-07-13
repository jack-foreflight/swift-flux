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

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct FluxObservationMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableMacro.self,
        ObservationTrackedMacro.self,
        ObservationIgnoredMacro.self,
        ObservationTrackingMacro.self,
    ]
}
