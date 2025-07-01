//
//  Event.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
public protocol Event {
    func register()
}
