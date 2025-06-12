//
//  Selector.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

/// A protocol for types that provide access to state via dynamic member lookup.
@dynamicMemberLookup
public protocol Selectable<State> {
    /// The type of state this selectable provides
    associatedtype State
    /// The current state value
    @MainActor var state: State { get }
}

/// A protocol for types that can select and transform state from a root state.
public protocol Selector<State> {
    /// The type of state this selector produces
    associatedtype State
    /// The root state type this selector operates on
    associatedtype Root: AppState
    /// Selects and transforms state from the root
    /// - Parameter root: The root state to select from
    /// - Returns: The selected/transformed state
    @MainActor func select(root: Root) -> State
}

@MainActor extension Selectable {
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
}

@MainActor extension Selectable where Self: Dispatcher {
    public func slice<Slice>(_ keyPath: KeyPath<State, Slice>) -> SliceSelector<Self, Slice> {
        SliceSelector(self, keyPath: keyPath)
    }

    public func map<S: Selector>(_ selector: S) -> MapSelector<Self, S.State> where State == S.Root {
        MapSelector(self) { state in selector.select(root: state) }
    }
}

/// A selector that provides access to a slice of state via a key path.
@MainActor public struct SliceSelector<Store: Selectable & Dispatcher, Slice>: Selectable, Dispatcher {
    public typealias State = Slice
    public let root: Store

    private let keyPath: KeyPath<Store.State, Slice>

    public init(_ root: Store, keyPath: KeyPath<Store.State, Slice>) {
        self.root = root
        self.keyPath = keyPath
    }

    public var state: Slice {
        root.state[keyPath: keyPath]
    }

    public func dispatch(_ action: some Action) {
        root.dispatch(action)
    }

    public func dispatch(_ action: some AsyncAction) {
        root.dispatch(action)
    }
}

/// A selector that transforms state using a mapping function.
@MainActor public struct MapSelector<Store: Selectable & Dispatcher, Mapped>: Selectable, Dispatcher {
    public typealias State = Mapped
    public let root: Store

    private let map: (Store.State) -> Mapped

    public init(_ root: Store, map: @escaping (Store.State) -> Mapped) {
        self.root = root
        self.map = map
    }

    public var state: Mapped {
        map(root.state)
    }

    public func dispatch(_ action: some Action) {
        root.dispatch(action)
    }

    public func dispatch(_ action: some AsyncAction) {
        root.dispatch(action)
    }
}
