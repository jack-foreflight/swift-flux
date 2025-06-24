//
//  LoggableAction.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/20/25.
//

import Foundation

/// Marker protocol for actions that can be logged for debugging or analytics
public protocol LoggableAction: Action {
    var description: String { get }
}

extension LoggableAction {
    public var description: String { "" }
}
