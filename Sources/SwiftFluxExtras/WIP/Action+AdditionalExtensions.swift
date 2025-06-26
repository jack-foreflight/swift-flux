//
//  Action+AdditionalExtensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation

extension Action {
    @available(*, deprecated, message: "Not Implemented")
    public func priority(_ priority: TaskPriority) -> some Action {
        Async {}
    }

    @available(*, deprecated, message: "Not Implemented")
    public func disabled() -> some Action {
        Async {}
    }

    @available(*, deprecated, message: "Not Implemented")
    public func cancelled() -> some Action {
        Async {}
    }

    @available(*, deprecated, message: "Not Implemented")
    public func onFail() -> some Action {
        Async {}
    }
}
