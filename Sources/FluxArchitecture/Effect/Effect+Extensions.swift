//
//  Effect+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Effect {
    public var event: some FluxArchitecture.Event {
        DidDispatchEvent { (_: any Action) in self }
    }
}
