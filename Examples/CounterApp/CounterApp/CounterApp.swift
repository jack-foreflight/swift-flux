//
//  CounterApp.swift
//  CounterApp - SwiftFlux Example
//
//

import SwiftFlux
import SwiftUI

/// We've defined an architecture based heavily on SwiftUI's declaritive syntax to handle the logic side of the application. The main components are as follows:
/// - Store: responsible for receiving dispatched actions and coordinating them
/// - State: The state should live within the Store. Currently this is unimplemented but a sample state in this case would be the StateModel we've defined below.
/// - Action: The core of the architecture that defines how state should be updated and any side effects. Actions can be thought of the "View" 's of the architecture in that you define the action body as to what happens. Actions can also be composed of other Actions and you would build their body's similar to how SwiftUI allows you to compose Views.

/// StateModel acts as a sample model that we will be passing around through the Views and the actions. Note that it conforms to SharedState so we are able to pass it around without explicitly defining the EnvironmentKey and the AppEnvironmentKey - the caveat being that if the Object is not able to be resolved, we through an error.

@Observable
public final class StateModel: Sendable, Identifiable {

    /// We use the id attribute in our testing to identify which instance of the StateModel we are currently using.

    public let id: String

    init(id: String) {
        self.id = id
    }
}

/// Our testbed is the CounterApp. This is where we declare the store and are testing the action dispatch.

@main
struct CounterApp: App {
    /// The Store is initialized within the root application
    @State private var store = Store()

    var body: some Scene {
        WindowGroup {
            Button {
                store.dispatch(OuterAction())
            } label: {
                Text("Dispatch Action")
            }
        }
        .environment(\.store, store)
    }
}

struct MiddleView: View {
    var body: some View {
        SubView()
    }
}

@StoreProviding
struct SubView: View {
    var body: some View {
        Button {
            dispatch(OuterAction())
        } label: {
            Text(select(StateModel.self).id)
        }
    }
}

/// Actions:
/// We are going to be testing with a basic action flow with composed Actions. OuterAction describes one to many actions within its body - in this case, we only have MiddleAction which has a modifier "environment" which we've defined in Action.swift

struct OuterAction: Action {
    let state = StateModel(id: "default")

    var body: some Action {
        MiddleAction()

            /// The environment modifier should mimic the SwiftUI environment modifier in that it will apply the environment to the entire scope of MiddleAction. This should also cascade down the action hierarchy so that "children" of MiddleAction also inherit this environment

            .environment(state)
    }
}

struct MiddleAction: Action {
    /// We are defining two additional states here that will be passed down to portions of the MiddleAction body, specifically the InnerActions

    let stateA = StateModel(id: "A")
    let stateB = StateModel(id: "B")

    /// Note that we've decorated this Action body with the resultBuilder @Parallel. This means that the contents of this Action should be executed in Parallel and if needed, should await the completion of all of the Actions for the Parallel action to complete.

    @Sequential
    var body: some Action {
        /// The execution of this InnerAction should operate with StateModel(id: "default") as we are not injecting any override state here. This should inherit from the parent.
        InnerAction()

        /// The execution of this InnerAction should operate on StateModel(id: "A") as this state is explicitly passed to this InnerAction via the environment modifier.
        InnerAction()
            .environment(stateA)

        /// The execution of this InnerAction should operate on StateModel(id: "B") as this state is explicitly passed to this InnerAction via the environment modifier.
        InnerAction()
            .environment(stateB)
    }
}

struct InnerAction: Action {
    /// We use the property wrapper @AppEnvironment to access environment values similarly to how SwiftUI allows you to access scoped instances of Environment with the @Environment property wrapper

    @Injected(StateModel.self) private var model

    let localState = LocalState(value: "")

    /// In this action body, we have defined an Async block which will allow you to execute async functionality. In this case, we are printing out the id of the environment model. We add a sleep here to simulate some asynchronous work and print out the model.id at the end. Since we are within a scoped instance of this Async work, the model.id should remain the same throughout the action.

    var body: some Action {
        Async {
            localState.value = model.id
            print("start - \(model.id)")
            try await Task.sleep(for: .seconds(1))
            print("end - EnvironmentState: \(model.id) LocalState: \(localState.value)")
        }
    }

    class LocalState {
        var value: String

        init(value: String) {
            self.value = value
        }
    }
}

/// Expectations:
/// The output of tapping on the Button should be:
/// start - default
/// start - A
/// start - B
/// end - EnvironmentState: A LocalState: A
/// end - EnvironmentState: default LocalState: default
/// end - EnvironmentState: B LocalState: B
/// **Note**: that for the "end" evaluations, the order of the statements is not deterministic because this will be based on the scheduling of the Tasks. But the EnvironmentState should always match what was passed in

/// Objectives:
/// The test simulated above is a very basic flow of how the architecture should behave. On a scale of 1-5 in terms of complexity, I would place this at a solid 2. I need a comprehensive test suite that will test all scenarios from level 1 to level 5 where level 5 would include highly nested action composition and data flow. The test suite should include State and Action definitions and should utilize the Store to handle the dispatching of actions.
/// - When running into swift concurrency compiliation errors, default to utilizing the @MainActor and then exploring other options for sendability as a backup.
/// - Ask clarifying questions if needed to proceed with your test suite creation
/// - ONLY operate within the framework for foundational code, if a supplemental type needs to be created to assist with the semantics, then ask me prior to implementation.
/// - Use this file as a reference for how you should structure your tests and actions
/// - Provide comments and documentation on all tests
