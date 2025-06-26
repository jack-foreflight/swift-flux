//
//  Debounce.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

extension Action {
    @available(*, deprecated, message: "Not Implemented")
    func debounce(for duration: some DurationProtocol) -> some Action {
        Async {}
    }
}

@available(*, deprecated, message: "Not Implemented")
struct Debounce<Body: Action>: Action, Identifiable {
    let id: AnyHashable
    var body: Body

    init(id: some Hashable, for duration: some DurationProtocol, body: () -> Body) {
        self.id = id
        self.body = body()
    }

    init(for duration: some DurationProtocol, body: () -> Body) where Body: Identifiable {
        let body = body()
        self.id = body.id
        self.body = body
    }
}
