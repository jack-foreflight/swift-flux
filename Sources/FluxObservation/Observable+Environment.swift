//
//  Observable+Environment.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/12/25.
//

import SwiftUI

public typealias Environment<T: FluxObservation.Observable> = EnvironmentObject<T>

extension View {
    public func environment(_ observable: some FluxObservation.Observable) -> some View {
        self.environmentObject(observable)
    }
}
