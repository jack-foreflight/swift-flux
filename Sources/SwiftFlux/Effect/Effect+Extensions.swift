//
//  Effect+Extensions.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

extension Effect where Condition == Bool {
    public static var always: Condition { true }
    public static var never: Condition { false }
}
