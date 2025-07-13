//
//  PublishEvent.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

#if canImport(Combine)
    import Combine

    public struct PublishEvent<Publisher: Combine.Publisher, Effect: FluxArchitecture.Effect>: Event where Publisher.Failure == Never {
        @Injected(Store.self) private var store
        @Injected(\.events) private var events

        private let publisher: Publisher
        private let effect: (Publisher.Output) -> Effect

        init(publisher: Publisher, effect: @escaping (Publisher.Output) -> Effect) {
            self.publisher = publisher
            self.effect = effect
        }

        public func register() {
            events.register {
                publisher.sink { store.handle(effect($0)) }
            }
        }
    }
#endif
