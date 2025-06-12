# SwiftFlux Examples

This directory contains example applications that demonstrate various aspects of the SwiftFlux architecture. Each example is designed to showcase different patterns, best practices, and use cases.

## 📚 Available Examples

### [CounterApp](./CounterApp/)
A comprehensive SwiftUI counter application that demonstrates:

- **Basic State Management**: Simple counter with increment/decrement
- **Nested State**: Multiple state objects working together
- **User Preferences**: Settings and configuration management
- **Async Operations**: Network simulation and error handling
- **Navigation**: Tab-based navigation with state management
- **History Tracking**: Array-based state with history management
- **UI Patterns**: Reactive UI, bindings, and animations

**Complexity**: Beginner to Intermediate  
**Platforms**: iOS 17+, macOS 14+  
**Topics**: State, Actions, Store, UI Integration, Async Patterns

## 🎯 Learning Path

### 1. Start with CounterApp
The CounterApp is the perfect starting point for learning SwiftFlux. It covers all the fundamental concepts:

- How to structure state with `@AppState`
- Creating and dispatching actions
- Setting up a store in SwiftUI
- Building reactive user interfaces
- Handling asynchronous operations

### 2. Key Concepts to Focus On

**State Management**
- Observe how state is defined and organized
- Notice the automatic registration of nested state
- See how computed properties work with state

**Action Patterns**
- Simple synchronous actions for immediate updates
- Async actions for network operations
- Composite actions that combine multiple operations
- Error handling and recovery patterns

**UI Integration**
- Environment object pattern for store access
- State-driven UI updates
- Binding controls to state
- Conditional rendering based on state

## 🔧 Building and Running Examples

Each example is a standalone Swift package that can be built and run independently:

```bash
cd Examples/CounterApp
swift build
swift run CounterApp
```

Or open in Xcode:
```bash
cd Examples/CounterApp
open Package.swift
```

## 📖 Code Organization

Each example follows a consistent structure:

```
ExampleApp/
├── Package.swift           # Swift package definition
├── README.md              # Example-specific documentation
└── Sources/
    └── ExampleApp/
        ├── AppState.swift      # State definitions
        ├── Actions.swift       # Action implementations
        ├── ExampleApp.swift    # App entry point
        └── Views/              # SwiftUI views
```

## 🎨 Customization and Extension

These examples are designed to be:

- **Educational**: Clear, well-commented code
- **Modifiable**: Easy to extend and customize
- **Realistic**: Patterns you'd use in real applications
- **Complete**: Full working applications, not just snippets

Feel free to:
- Modify the examples to try different approaches
- Add new features to explore SwiftFlux capabilities
- Use them as starting points for your own applications

## 🆘 Getting Help

If you're having trouble with any example:

1. **Check the README**: Each example has detailed documentation
2. **Read the Comments**: Code is extensively commented for learning
3. **Review the Main Docs**: See the [main SwiftFlux documentation](../README.md)
4. **Open an Issue**: If you find bugs or have suggestions

## 🔮 Future Examples

We're planning to add more examples covering:

- **TodoApp**: Task management with CRUD operations
- **WeatherApp**: Network requests and data caching
- **ChatApp**: Real-time updates and WebSocket integration
- **ShoppingApp**: Complex state management with multiple entities
- **GameApp**: High-frequency state updates and performance optimization

## 🤝 Contributing Examples

Want to contribute an example? We'd love to see:

- **Clear Use Cases**: Examples that demonstrate specific patterns
- **Good Documentation**: Well-commented code and clear README
- **Real-World Patterns**: Practical examples developers will actually use
- **Different Complexities**: From simple to advanced patterns

Please see our [contribution guidelines](../CONTRIBUTING.md) for more details.