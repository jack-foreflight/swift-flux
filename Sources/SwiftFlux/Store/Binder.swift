//
//  Binder.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

@MainActor
public protocol Binder {
    var store: Store { get }
}

extension Binder {

}
