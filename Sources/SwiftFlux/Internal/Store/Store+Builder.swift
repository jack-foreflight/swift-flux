//
//  Store+Builder.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation

extension Store {
    public static func configure() -> Builder {
        fatalError()
    }

    public static func build() -> Store {
        fatalError()
    }

    public class Builder {
        init() {}

        public func withState() -> Builder {
            self
        }

        public func withEffects() -> Builder {
            self
        }

        public func withEnvironment() -> Builder {
            self
        }

        public func build() -> Store {
            fatalError()
        }
    }
}
