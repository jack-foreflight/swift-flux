//
//  EventRegistrar.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import Foundation

#if canImport(Combine)
    import Combine
#endif

@MainActor
final class EventRegistrar: Injection {
    private var effects: [any Effect] = []
    private var willDispatch: [(any Action) -> Void] = []
    private var didDispatch: [(any Action) -> Void] = []

    nonisolated init() {}

    func register(_ event: @autoclosure () -> some Event) {

    }

    func registerWillDispatch(_ effect: (any Action) -> Void) {

    }

    func registerDidDispatch(_ effect: (any Action) -> Void) {

    }

    func willDispatch(_ action: some Action) {
        for event in willDispatch {
            event(action)
        }
    }

    func didDispatch(_ action: some Action) {
        for event in didDispatch {
            event(action)
        }
    }

    #if canImport(Combine)
        private var cancellables: Set<AnyCancellable> = []

        func register(_ cancellable: AnyCancellable) {
            cancellables.insert(cancellable)
        }

        func register(_ cancellable: () -> AnyCancellable) {
            cancellables.insert(cancellable())
        }

        func register(_ cancellables: AnyCancellable...) {
            self.cancellables.formUnion(cancellables)
        }
    #endif

    public static nonisolated let defaultValue: EventRegistrar = EventRegistrar()
}

extension InjectionValues {
    var events: EventRegistrar {
        get { self[EventRegistrar.self] }
        set { self[EventRegistrar.self] = newValue }
    }
}
