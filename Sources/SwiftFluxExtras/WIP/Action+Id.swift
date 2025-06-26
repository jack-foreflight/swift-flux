//
//  Action+Id.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

extension Action {
    public func id(_ id: some Hashable) -> some Action {
        IdentifiableAction(id: id, body: self)
    }
}

private struct IdentifiableAction<Body: Action>: Action, Identifiable {
    let id: AnyHashable
    let body: Body

    init(id: some Hashable, body: @autoclosure () -> Body) {
        self.id = id
        self.body = body()
    }
}
