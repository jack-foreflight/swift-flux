//
//  Store+Environment.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation
import SwiftUI

extension Store: AppEnvironmentKey, EnvironmentKey {
    public static nonisolated let defaultValue: Store = Store()
    public static nonisolated func build(container: Container) -> Store { Store() }
}
