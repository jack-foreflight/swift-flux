//
//  Store.swift
//  SwiftFlux
//
//  Created by Jack Zhao on 6/9/25.
//

import Foundation

@Observable
public final class Store {
    private let stateRegistrar: StateRegistrar = StateRegistrar()
    private let actionDispatcher: ActionDispatcher = ActionDispatcher()
    @ObservationIgnored private var environment: AppEnvironmentValues = AppEnvironmentValues()
}

extension Store {
    public func dispatch(_ action: some Action) {
        withEnvironment(environment) {
            actionDispatcher.perform(action: action, state: resolve())
        }
    }

    public func dispatch(_ action: some AsyncAction) {
        withEnvironment(environment) {
            actionDispatcher.perform(action: action, store: self)
        }
    }
}

extension Store {
    func register<State: AppState>(state: State) {
        stateRegistrar.register(state: state)
    }

    func resolve<State: AppState>() -> State {
        resolve(State.self)
    }

    func resolve<State: AppState>(_ type: State.Type) -> State {
        guard let state = stateRegistrar.resolve(type) else {
            // Log error
            preconditionFailure()
        }
        return state
    }
}

extension Store {

}

extension Store {
    internal class StateRegistrar {
        private var state: [AnyHashable: any AppState] = [:]
        private var effects: [AnyHashable: [any Effect]] = [:]

        func register<each Effect: SwiftFlux.Effect>(effects: repeat each Effect) {
            for effect in repeat each effects {
                register(effect: effect)
            }
        }

        func register<State: AppState>(effect: some Effect<State>) {
            self.effects[State.id]?.append(effect)
        }

        func register<State: AppState>(state: State) {
            self.state[State.id] = state
        }

        func resolve<State: AppState>(_ type: State.Type) -> State? {
            self.state[State.id] as? State
        }
    }
}

extension Store {
    internal class ActionDispatcher {
        private var handlers: [AnyHashable: [any Handler]] = [:]
        private var asyncActions: [AnyHashable: [UUID: Task<Void, Never>]] = [:]
        private var asyncHandlers: [AnyHashable: [any AsyncHandler]] = [:]

        func perform<Action: SwiftFlux.Action, State: AppState>(
            action: Action,
            state: State
        ) where Action.State == State {
            guard action.precondition(state: state) else {
                // Log preconditionFailure
                return
            }
            let handlers = handlers[Action.id]?.compactMap { $0 as? any Handler<Action> } ?? []
            defer {
                for handler in handlers {
                    handler.didPerform(action: action)
                }
            }
            for handler in handlers {
                handler.willPerform(action: action)
            }
            do {
                try action.body(state: state)
            } catch {
                switch error {
                case let error as Action.Failure:
                    action.failed(error: error, state: state)
                default:
                    // Log errorCondition failure
                    break
                }
            }
        }

        func perform<Action: SwiftFlux.AsyncAction>(
            action: Action,
            store: Store
        ) {
            let id = UUID()
            let task = Task(priority: action.priority) {
                guard await action.precondition(store: store) else {
                    // Log preconditionFailure
                    return
                }
                let handlers =
                    asyncHandlers[Action.id]?.compactMap { $0 as? any AsyncHandler<Action> } ?? []
                defer {
                    for handler in handlers {
                        handler.didPerform(action: action)
                    }
                }
                for handler in handlers {
                    handler.willPerform(action: action)
                }
                do {
                    try await action.body(store: store)
                } catch {
                    switch error {
                    case let error as Action.Failure:
                        await action.failed(error: error, store: store)
                    default:
                        // Log errorCondition failure
                        break
                    }
                }
            }
            asyncActions[Action.id]?[id] = task
        }
    }
}
