//
//  Binder.swift
//  swift-flux
//
//  Created by Jack Zhao on 7/1/25.
//

import SwiftUI

@MainActor
public protocol Binder: Selector, Dispatcher {}

extension Binder {
    public func bind<State>(_ state: State, _ action: @escaping (State) -> some Action) -> Binding<State> {
        Binding {
            state
        } set: { newValue in
            dispatch(action(newValue))
        }
    }

    public func bind<Selection: SwiftFlux.Selection>(_ selection: Selection, _ action: some Action) -> Binding<Selection.State> {
        Binding {
            store.select(selection)
        } set: { newValue in
            dispatch(action)
        }
    }

    public func bind<Selection: SwiftFlux.Selection>(_ selection: Selection, _ action: @escaping (Selection.State) -> some Action) -> Binding<Selection.State> {
        Binding {
            store.select(selection)
        } set: { newValue in
            dispatch(action(newValue))
        }
    }

    public func bind<State>(_ keyPath: KeyPath<Store, State>, _ action: some Action) -> Binding<State> {
        Binding {
            store.select(KeyPathSelection(keyPath: keyPath))
        } set: { newValue in
            dispatch(action)
        }
    }

    public func bind<State>(_ keyPath: KeyPath<Store, State>, _ action: @escaping (State) -> some Action) -> Binding<State> {
        Binding {
            store.select(KeyPathSelection(keyPath: keyPath))
        } set: { newValue in
            dispatch(action(newValue))
        }
    }

    public func bind<State: Sendable>(_ type: State.Type, _ action: some Action) -> Binding<State> {
        Binding {
            store.select(StateTypeSelection())
        } set: { newValue in
            dispatch(action)
        }
    }

    public func bind<State: Sendable>(_ type: State.Type, _ action: @escaping (State) -> some Action) -> Binding<State> {
        Binding {
            store.select(StateTypeSelection())
        } set: { newValue in
            dispatch(action(newValue))
        }
    }

    public func bind<SharedState: Sendable, State>(_ map: @escaping (SharedState) -> State, _ action: some Action) -> Binding<State> {
        Binding {
            store.select(StateMapSelection(map: map))
        } set: { newValue in
            dispatch(action)
        }
    }

    public func bind<SharedState: Sendable, State>(_ map: @escaping (SharedState) -> State, _ action: @escaping (State) -> some Action) -> Binding<State> {
        Binding {
            store.select(StateMapSelection(map: map))
        } set: { newValue in
            dispatch(action(newValue))
        }
    }

    public func bind<SharedState: Sendable, State>(_ keyPath: KeyPath<SharedState, State>, _ action: some Action) -> Binding<State> {
        Binding {
            store.select(StateKeyPathSelection(keyPath: keyPath))
        } set: { newValue in
            dispatch(action)
        }
    }

    public func bind<SharedState: Sendable, State>(_ keyPath: KeyPath<SharedState, State>, _ action: @escaping (State) -> some Action) -> Binding<State> {
        Binding {
            store.select(StateKeyPathSelection(keyPath: keyPath))
        } set: { newValue in
            dispatch(action(newValue))
        }
    }
}
