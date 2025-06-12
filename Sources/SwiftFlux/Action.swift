//
//  Action.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/10/25.
//

import Foundation

/// A protocol representing a synchronous state mutation in the Flux architecture.
public protocol Action {
    /// The type of state this action operates on
    associatedtype State: AppState
    /// The type of error this action can produce
    associatedtype Failure = any Error

    /// Performs the main operation of this action on the given state
    /// - Parameter state: The state object to modify
    func operation(state: State)
    /// Called when the action fails with an error
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - state: The state object at the time of failure
    func failed(error: Failure, state: State)
}

extension Action where Failure == Never {
    public func failed(error: Never, state: State) {}
}

/// A protocol representing an asynchronous operation in the Flux architecture.
/// 
/// AsyncAction provides a simplified way to perform asynchronous work that may
/// need to dispatch multiple actions or access state during execution. The action
/// receives a Store instance that provides both state access and dispatch capabilities.
///
/// Example usage:
/// ```swift
/// struct LoadUserAction: AsyncAction {
///     typealias State = AppState
///     let userId: String
///     
///     func operation(store: Store<AppState>) async {
///         await store.dispatch(SetLoadingAction(true))
///         
///         do {
///             let user = try await userService.loadUser(id: userId)
///             await store.dispatch(SetUserAction(user))
///         } catch {
///             await failed(error: error, store: store)
///         }
///         
///         await store.dispatch(SetLoadingAction(false))
///     }
///     
///     func failed(error: any Error, store: Store<AppState>) async {
///         await store.dispatch(SetErrorAction(error.localizedDescription))
///     }
/// }
/// ```
public protocol AsyncAction {
    associatedtype State: AppState

    /// The type of error this action can produce
    associatedtype Failure = any Error

    /// Performs the main asynchronous operation of this action
    /// - Parameter store: The store providing state access and action dispatching
    func operation(store: Store<State>) async
    /// Called when the action fails with an error
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - store: The store at the time of failure
    func failed(error: Failure, store: Store<State>) async
}

extension AsyncAction where Failure == Never {
    public func failed(error: Never, store: Store<State>) async {}
}

/// A convenience action that wraps a closure for simple state mutations.
public struct Mutate<State: AppState>: Action {
    private let operation: (State) -> Void

    /// Creates a new mutation action with the given operation
    /// - Parameter operation: The closure that will modify the state
    public init(_ operation: @escaping (State) -> Void) {
        self.operation = operation
    }

    public func operation(state: State) {
        operation(state)
    }
}

/// A result builder for composing multiple actions into a sequence.
@resultBuilder
public struct ActionBuilder {
    public static func buildBlock(_ actions: any Action...) -> [any Action] {
        actions
    }

    public static func buildOptional(_ action: [any Action]?) -> [any Action] {
        action ?? []
    }

    public static func buildEither(first action: [any Action]) -> [any Action] {
        action
    }

    public static func buildEither(second action: [any Action]) -> [any Action] {
        action
    }

    public static func buildArray(_ actions: [[any Action]]) -> [any Action] {
        actions.flatMap { $0 }
    }

    public static func buildExpression(_ action: any Action) -> [any Action] {
        [action]
    }

    public static func buildExpression(_ actions: [any Action]) -> [any Action] {
        actions
    }
}

// MARK: - Action Traits

/// Marker protocol for actions that handle their own dispatch logic
public protocol ActionHandler {}

/// Marker protocol for actions that can compose other actions
public protocol ActionComposer {}

/// Marker protocol for actions that have preconditions that must be met
public protocol PreconditionAction: Action {}

/// Marker protocol for actions that can be logged for debugging or analytics
public protocol LoggableAction: Action {}

/// Marker protocol for actions that can be reversed/undone
public protocol ReversableAction: Action {}

/// Marker protocol for actions that can be persisted to storage
public protocol PersistableAction: Action {}

/// Marker protocol for actions that can be published to external systems
public protocol PublishableAction: Action {}

/// Marker protocol for actions that can trigger notifications
public protocol NotifiableAction: Action {}

/// Marker protocol for async actions that run in isolation
public protocol IsolatedAction: AsyncAction {}

/// Marker protocol for async actions that can be cancelled
public protocol CancellableAction: AsyncAction {}

/// Marker protocol for async actions that can be debounced
public protocol DebouncableAction: AsyncAction {}

/// Marker protocol for async actions that can run concurrently
public protocol ConcurrentActions: AsyncAction & ActionComposer {}

/// Marker protocol for async actions that must run sequentially
public protocol SequentialActions: AsyncAction & ActionComposer {}
