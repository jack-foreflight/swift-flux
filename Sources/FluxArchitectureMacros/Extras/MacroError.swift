//
//  MacroError.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

struct MacroError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
