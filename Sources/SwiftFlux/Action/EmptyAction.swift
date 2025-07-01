//
//  EmptyAction.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/28/25.
//

import Foundation

public struct EmptyAction: Action {
    public init() {}
    public var body: some Action { Sync {} }
}
