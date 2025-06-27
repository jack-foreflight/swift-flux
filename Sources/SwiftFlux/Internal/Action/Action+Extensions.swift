//
//  Action+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

extension Action {
    @MainActor public func sync() {
        body.sync()
    }

    @MainActor public func async() async {
        await body.async()
    }
}
