//
//  ActionModifier.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/25/25.
//

import Foundation
import SwiftUI

public protocol ActionModifier {
    associatedtype Body: Action
    typealias Content = _ActionModifier_Content<Self>

    func body(content: Self.Content) -> Body
}

public struct _ActionModifier_Content<Modifier: ActionModifier> {

}
