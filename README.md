# SwiftFlux

A modern Swift implementation of the Flux architecture pattern, leveraging Swift's Observation framework for reactive state management in iOS and macOS applications.

## Features

- **Observable State Management**: Built on Swift's Observation framework for automatic UI updates
- **Type-Safe Actions**: Strongly-typed synchronous and asynchronous actions with compile-time safety  
- **Macro-Powered State**: `@AppState` macro for automatic observable state generation
- **Flexible Architecture**: Support for nested states, selectors, and state composition
- **Action Builders**: SwiftUI-style result builders for composing multiple actions
- **Async Support**: First-class support for async operations with proper task management
- **Store Composition**: Register and manage multiple state objects within a single store

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+

## Installation

### Swift Package Manager

Add SwiftFlux to your project via Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jack-foreflight/swift-flux.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your State

Use the `@AppState` macro to create observable state classes:

```swift
import SwiftFlux

@AppState
class AppState {
    var count: Int = 0
    var isLoading: Bool = false
    var user: User?
}
```

### 2. Create Actions

Define actions that modify your state:

```swift
struct IncrementAction: Action {
    typealias State = AppState
    
    func operation(state: AppState) {
        state.count += 1
    }
}

struct LoadUserAction: AsyncAction {
    typealias State = AppState
    let userId: String
    
    func operation(store: some Selectable<AppState> & Dispatcher) async {
        await store.dispatch(ToggleLoadingAction())
        do {
            let user = try await UserService.loadUser(id: userId)
            await store.dispatch(SetUserAction(user: user))
        } catch {
            await failed(error: error, store: store)
        }
        await store.dispatch(ToggleLoadingAction())
    }
    
    func failed(error: Error, store: some Selectable<AppState> & Dispatcher) async {
        // Handle error
        print("Failed to load user: \(error)")
    }
}

struct SetUserAction: Action {
    typealias State = AppState
    let user: User
    
    func operation(state: AppState) {
        state.user = user
    }
}
```

### 3. Set Up Your Store

Create your store with the state type:

```swift
let store = Store(AppState())
```

### 4. Use in SwiftUI

```swift
import SwiftUI

struct ContentView: View {
    @State private var store = Store(AppState())
    
    var body: some View {
        VStack {
            Text("Count: \(store.state.count)")
            
            Button("Increment") {
                store.dispatch(IncrementAction())
            }
            
            Button("Load User") {
                store.dispatch(LoadUserAction(userId: "123"))
            }
            
            if store.state.isLoading {
                ProgressView()
            }
        }
    }
}
```

## Advanced Usage

### Action Builders

Compose multiple actions using the `@ActionBuilder`:

```swift
store.dispatch {
    IncrementAction()
    SetLoadingAction(isLoading: true)
    // Conditional actions
    if someCondition {
        AnotherAction()
    }
}
```

### State Selectors

Create focused views of your state using selectors:

```swift
// Access nested state
let userStore = store.slice(\.user)

// Transform state with custom selectors
struct UserNameSelector: Selector {
    typealias Root = AppState
    typealias State = String
    
    func select(root: AppState) -> String {
        root.user?.name ?? "Unknown"
    }
}

let nameStore = store.map(UserNameSelector())
```

### Nested States

States automatically register their `AppState` properties:

```swift
@AppState
class UserState {
    var currentUser: User?
    var preferences: UserPreferences = UserPreferences()
}

@AppState  
class NavigationState {
    var currentTab: Tab = .home
    var navigationStack: [Screen] = []
}

@AppState
class AppState {
    var count: Int = 0
    var userState = UserState()        // Auto-registered
    var navigationState = NavigationState()  // Auto-registered
}

let store = Store(AppState())
```

### Task Management

SwiftFlux automatically manages async action tasks:

```swift
// Cancel all running async actions
store.cancelAllActions()
```

## Core Concepts

### AppState
Classes conforming to `AppState` represent observable state that can be registered with a store. Use the `@AppState` macro for automatic implementation.

### Actions
- **Action**: Synchronous state mutations
- **AsyncAction**: Asynchronous operations that can dispatch other actions
- Both support error handling through the `failed` method

### Store
The central hub that manages state and dispatches actions. Supports state registration, action dispatching, and provides observable state access.

### Selectors
Tools for creating focused, transformed views of your state without duplicating data.

## License

[Add your license information here]
