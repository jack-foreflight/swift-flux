//
//  CounterApp.swift
//  CounterApp - SwiftFlux Example
//
//  This is the main app entry point that demonstrates how to set up
//  a SwiftFlux store and provide it to your SwiftUI view hierarchy.
//

import SwiftFlux
import SwiftUI

@Observable
final class TestFlight: SharedState {
    let name: String

    init(name: String) {
        self.name = name
    }

    func register(in store: SwiftFlux.Store) {}
}

struct InnerAction: Action {
    @AppEnvironment(TestFlight.self) private var flight

    var body: some Action {
        Async {
            print("start")
            print(flight.name)
            try await Task.sleep(for: .seconds(1))
            print("end")
        }
    }
}

struct MiddleAction: Action {
    let state = TestFlight(name: "A")
    let state2 = TestFlight(name: "B")

    @Parallel
    var body: some Action {
        InnerAction()
        InnerAction()
            .environment(state)
        InnerAction()
            .environment(state2)
    }
}

struct OuterAction: Action {
    let state = TestFlight(name: "default")

    var body: some Action {
        MiddleAction()
            .environment(state)
    }
}

/// The main app structure.
/// This demonstrates how to initialize and provide a SwiftFlux store to your app.
@main
struct CounterApp: App {
    /// The main store for our application.
    /// In SwiftFlux, you typically have one store per app that manages all state.
    /// The @State property wrapper ensures the store is preserved across view updates.
    //    @State private var store = Store(CounterAppState())
    @State private var store = Store()

    var body: some Scene {
        WindowGroup {
            Button {
                store.dispatch(OuterAction())
            } label: {
                Text("Tap")
            }
            //            ContentView()
            //                .environment(store)
            //                // Load saved data when the app starts
            //                .task {
            //                    store.dispatch(LoadDataAction())
            //                }
        }
    }
}
//
///// The main content view that manages the tab-based navigation.
///// This demonstrates how to access and react to store state in SwiftUI.
//struct ContentView: View {
//    /// Access the store via explicit dependency injection.
//    /// This demonstrates explicit dependency passing instead of Environment.
//    @Environment(Store<CounterAppState>.self) var store
//
//    var body: some View {
//        TabView(
//            // Binding the tab selection to our navigation state
//            selection: store.bind(\.navigation.selectedTab, to: SelectTabAction.init)
//        ) {
//            // Counter Tab
//            CounterView()
//                .tabItem {
//                    Image(systemName: "plus.minus")
//                    Text("Counter")
//                }
//                .tag(AppTab.counter)
//
//            // History Tab
//            HistoryView()
//                .tabItem {
//                    Image(systemName: "clock")
//                    Text("History")
//                }
//                .tag(AppTab.history)
//
//            // Settings Tab
//            SettingsView()
//                .tabItem {
//                    Image(systemName: "gear")
//                    Text("Settings")
//                }
//                .tag(AppTab.settings)
//        }
//        // Show error alerts when they occur
//        .alert(
//            "Error",
//            isPresented: store.bind {
//                $0.loading.lastError != nil
//            } to: { _ in
//                ClearErrorAction()
//            }
//        ) {
//            Button("OK") {
//                store.dispatch(ClearErrorAction())
//            }
//        } message: {
//            Text(store.state.loading.lastError ?? "An unknown error occurred")
//        }
//    }
//}
