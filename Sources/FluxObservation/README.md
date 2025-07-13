# FluxObservation

FluxObservation backdeloys Apple's Observation framework from iOS 17 to support earlier iOS versions. It provides the same declarative observation capabilities as the official framework while maintaining compatibility with older iOS versions.

## Purpose

The iOS 17+ Observation framework introduced a powerful and efficient way to track state changes in Swift applications. However, this framework is only available on iOS 17 and later. FluxObservation bridges this gap by providing:

- **Backward Compatibility**: Use iOS 17+ observation patterns on earlier iOS versions
- **Identical API**: Maintains the same `@Observable` macro syntax and behavior
- **Seamless Migration**: Easy transition to the official framework when dropping support for pre-iOS 17 versions
- **SwiftUI Integration**: Additional utilities for SwiftUI observation tracking on pre-iOS 17 versions

## Contents

### Core Files

#### `Observable.swift`
- Defines the `Observable` protocol that serves as the base for all observable types
- Exports the `@Observable` macro for marking classes as observable
- Provides `@ObservationTracked` and `@ObservationIgnored` macros for fine-grained control
- Includes `@ObservationTracking` macro for SwiftUI view observation (backdeployment utility)

#### `ObservationRegistrar.swift`
- Implements the core observation infrastructure
- Manages property access tracking and change notifications
- Handles willSet/didSet observers for observable properties
- Provides thread-safe observation registration and cancellation

#### `ObservationTracking.swift`
- Implements the `withObservationTracking` function for manual observation setup
- Provides FluxObservation-specific tracking functions with willSet/didSet separation
- Includes `WithObservationTracking` SwiftUI view for manual observation wrapping (backdeployment utility)
- Manages access list generation and tracking installation

#### `Observations.swift`
- Defines the `Observations` async sequence for reactive state observation
- Provides transactional boundaries for state changes using Swift Concurrency
- Supports iteration-based observation with cancellation handling
- Implements isolation-aware observation tracking

### Supporting Files

#### `ManagedCriticalState.swift`
- Provides thread-safe state management using `OSAllocatedUnfairLock`
- Implements critical sections for concurrent access to observation state
- Simplified from the original ManagedBuffer implementation for better performance

#### `ThreadLocal.swift`
- Implements thread-local storage for observation tracking context
- Uses pthread APIs for cross-platform compatibility
- Manages per-thread observation access lists

#### `Observable+Environment.swift`
- Provides SwiftUI environment integration for observable objects
- Defines `Environment<T>` typealias for observable types
- Extends `View` with `.environment()` modifier for observable injection

## Key Features

### Automatic Property Observation
The `@Observable` macro automatically generates observation infrastructure for class properties:

```swift
@Observable
class CounterState {
    var count: Int = 0    // Automatically observable
    var step: Int = 1     // Automatically observable
}
```

### Manual Observation Control
Fine-grained control over what gets observed:

```swift
@Observable
class TimerState {
    var seconds: Int = 0       // Observable
    
    @ObservationIgnored
    private var timer: Timer?  // Not observable
}
```

### SwiftUI Integration (Backdeployment Features)
Two approaches for SwiftUI observation on pre-iOS 17 versions:

1. **@ObservationTracking macro** - Automatic observation for entire views:
```swift
@ObservationTracking
struct CounterView: View {
    @Environment var state: CounterState
    
    var body: some View {
        Text("\(state.count)")  // Automatically tracked
    }
}
```

2. **WithObservationTracking view** - Manual observation for specific content:
```swift
struct CounterView: View {
    @Environment var state: CounterState
    
    var body: some View {
        WithObservationTracking {
            Text("\(state.count)")  // Manually tracked
        }
    }
}
```

### Async Observation
Reactive state observation using Swift Concurrency:

```swift
let observations = Observations {
    return state.count
}

for await count in observations {
    print("Count changed to: \(count)")
}
```

## Migration Path

When your minimum deployment target reaches iOS 17+, you can migrate to the official Observation framework:

1. Replace `import FluxObservation` with `import Observation`
2. Remove `@ObservationTracking` macros from SwiftUI views
3. Remove `WithObservationTracking` view wrappers
4. Update `@EnvironmentObject` or FluxObservation's `@Environment` typealias to the standard SwiftUI `@Environment`

The `@Observable` macro syntax remains identical, making the transition seamless.

## Thread Safety

FluxObservation is designed to be thread-safe:
- Uses `OSAllocatedUnfairLock` for critical sections
- Implements proper isolation boundaries for concurrent access
- Supports Swift Concurrency patterns with actor isolation

## Performance

The framework is optimized for performance:
- Minimal overhead observation tracking
- Efficient property access registration
- Lazy observation setup to avoid unnecessary work
- Thread-local storage for reduced contention

## Limitations

As a backdeployment, FluxObservation has some limitations compared to the official iOS 17+ framework:
- Requires additional macros for SwiftUI integration
- May have slight performance differences due to implementation constraints
- Does not include all advanced features of the official framework

## See Also

- **FluxObservationMacros**: The macro implementations that power the `@Observable` functionality
- **CounterApp Example**: A comprehensive example demonstrating all observation patterns
- **Swift Observation Documentation**: Official documentation for the iOS 17+ framework
