//
//  Selector+SwiftUI.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/12/25.
//

import Foundation
import SwiftUI

extension Selectable where Self: Dispatcher {
    @MainActor public func bind<T>(_ keyPath: KeyPath<State, T>, to action: some Action) -> Binding<T> {
        Binding {
            state[keyPath: keyPath]
        } set: { _ in
            dispatch(action)
        }
    }

    @MainActor public func bind<T>(_ map: @escaping (State) -> T, to action: some Action) -> Binding<T> {
        Binding {
            map(state)
        } set: { _ in
            dispatch(action)
        }
    }

    @MainActor public func bind<T>(keyPath: KeyPath<State, T>, to action: some AsyncAction) -> Binding<T> {
        Binding {
            state[keyPath: keyPath]
        } set: { _ in
            dispatch(action)
        }
    }

    @MainActor public func bind<T>(_ map: @escaping (State) -> T, to action: some AsyncAction) -> Binding<T> {
        Binding {
            map(state)
        } set: { _ in
            dispatch(action)
        }
    }

    @MainActor public func bind<T>(_ keyPath: KeyPath<State, T>, to action: @escaping (T) -> some Action) -> Binding<T> {
        Binding {
            state[keyPath: keyPath]
        } set: {
            dispatch(action($0))
        }
    }

    @MainActor public func bind<T>(_ map: @escaping (State) -> T, to action: @escaping (T) -> some Action) -> Binding<T> {
        Binding {
            map(state)
        } set: {
            dispatch(action($0))
        }
    }

    @MainActor public func bind<T>(keyPath: KeyPath<State, T>, to action: @escaping (T) -> some AsyncAction) -> Binding<T> {
        Binding {
            state[keyPath: keyPath]
        } set: {
            dispatch(action($0))
        }
    }

    @MainActor public func bind<T>(_ map: @escaping (State) -> T, to action: @escaping (T) -> some AsyncAction) -> Binding<T> {
        Binding {
            map(state)
        } set: {
            dispatch(action($0))
        }
    }
}
