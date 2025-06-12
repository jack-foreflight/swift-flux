# SwiftFlux Counter Example App

This example app demonstrates how to build a SwiftUI application using the SwiftFlux architecture. It showcases various patterns and best practices for state management, action dispatching, and reactive UI updates.

## 🎯 What This Example Demonstrates

### Core SwiftFlux Concepts

1. **State Management with `@AppState`**
   - How to define observable state classes using the `@AppState` macro
   - Nested state organization and automatic registration
   - Computed properties based on state

2. **Action Patterns**
   - Synchronous actions for immediate state updates
   - Asynchronous actions for network/storage operations
   - Composite actions that combine multiple operations
   - Error handling in actions

3. **Store Integration**
   - Setting up a store in SwiftUI apps
   - Accessing state through environment objects
   - Using selectors to focus on specific state slices

4. **Reactive UI**
   - Automatic UI updates when state changes
   - Binding SwiftUI controls to state
   - Conditional UI based on state values

## 🏗️ Architecture Overview

```
CounterApp/
├── AppState.swift          # State definitions
├── Actions.swift           # All action implementations
├── CounterApp.swift        # App entry point and store setup
├── CounterView.swift       # Main counter interface
├── HistoryView.swift       # History display and management
└── SettingsView.swift      # Preferences and configuration
```

## 📱 Features Demonstrated

### Counter Functionality
- **Basic Operations**: Increment, decrement, reset
- **Step Size Control**: Configure increment/decrement amount
- **Value Setting**: Jump to specific values
- **History Tracking**: Automatic history of previous values
- **Milestone Celebration**: UI feedback for special values

### User Preferences
- **Animation Control**: Enable/disable UI animations
- **Sound Control**: Toggle sound effects
- **Theme Selection**: Light, dark, or system theme
- **History Limits**: Configure maximum history items

### Navigation & UI
- **Tab-based Navigation**: Multiple views with state-driven selection
- **Modal Presentation**: Sheets and alerts
- **Loading States**: Progress indicators for async operations
- **Error Handling**: User-friendly error display

### Async Operations
- **Data Persistence**: Save/load preferences simulation
- **Error Simulation**: Realistic error scenarios
- **Loading States**: Progress feedback during operations
- **Cancellation**: Proper cleanup of async tasks

## 🔍 Key SwiftFlux Patterns Shown

### 1. State Definition
```swift
@AppState
class CounterState {
    var value: Int = 0
    var stepSize: Int = 1
    var history: [Int] = []
}
```

### 2. Action Implementation
```swift
struct IncrementAction: Action, LoggableAction {
    typealias State = CounterState
    
    func operation(state: CounterState) {
        state.history.append(state.value)
        state.value += state.stepSize
    }
}
```

### 3. Store Setup
```swift
@main
struct CounterApp: App {
    @State private var store = Store(CounterAppState())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
```

### 4. UI Integration
```swift
struct CounterView: View {
    @EnvironmentObject var store: Store<CounterAppState>
    
    var body: some View {
        Text("\\(store.state.counter.value)")
            .onTapGesture {
                store.dispatch(IncrementAction())
            }
    }
}
```

### 5. State Selectors
```swift
private var counterStore: SliceSelector<Store<CounterAppState>, CounterState> {
    store.slice(\\.counter)
}
```

### 6. Async Actions
```swift
struct SavePreferencesAction: AsyncAction, CancellableAction {
    func operation(store: some Selectable<CounterAppState> & Dispatcher) async {
        await store.dispatch(SetLoadingAction(isLoading: true, operation: "saving"))
        
        do {
            try await saveToStorage()
            await store.dispatch(ClearErrorAction())
        } catch {
            await failed(error: error, store: store)
        }
        
        await store.dispatch(SetLoadingAction(isLoading: false, operation: "saving"))
    }
}
```

## 🚀 Running the Example

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ / macOS 14.0+
- Swift 6.0+

### Build and Run
```bash
cd Examples/CounterApp
swift build
swift run CounterApp
```

Or open in Xcode:
```bash
open Package.swift
```

## 📚 Learning Guide

### For Beginners
1. Start with `AppState.swift` to understand state structure
2. Look at `CounterView.swift` for basic UI integration
3. Examine simple actions like `IncrementAction`
4. Follow the data flow: Action → State → UI

### For Intermediate Developers
1. Study the async actions in `Actions.swift`
2. Explore state composition in nested AppState classes
3. Look at selector usage for focused state access
4. Examine error handling patterns

### For Advanced Developers
1. Study the action trait implementations
2. Look at composite action patterns
3. Examine the loading state management
4. Consider scalability patterns for larger apps

## 🎨 Customization Ideas

Try extending this example with:

- **Persistence**: Add Core Data or UserDefaults integration
- **Networking**: Add remote counter synchronization
- **Animation**: Enhance visual feedback with custom animations
- **Testing**: Add unit tests for actions and state
- **Accessibility**: Improve VoiceOver and accessibility support
- **Localization**: Add multi-language support

## 📝 Best Practices Demonstrated

1. **Single Source of Truth**: All state lives in the store
2. **Unidirectional Data Flow**: Actions → State → UI
3. **Separation of Concerns**: Clear boundaries between state, actions, and UI
4. **Type Safety**: Strong typing throughout the architecture
5. **Error Handling**: Proper error propagation and user feedback
6. **Performance**: Efficient state updates and UI rendering
7. **Testability**: Clear interfaces for testing actions and state

## 🔗 Related Documentation

- [SwiftFlux README](../../README.md) - Main framework documentation
- [API Reference](../../Sources/SwiftFlux/) - Detailed API documentation
- [Swift Documentation](https://swift.org/documentation/) - Swift language guide

## 🤝 Contributing

Found an issue or want to improve this example? Contributions are welcome! Please see the main repository's contribution guidelines.