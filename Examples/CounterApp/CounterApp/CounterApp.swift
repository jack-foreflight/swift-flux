//
//  CounterApp.swift
//  CounterApp - SwiftFlux Example
//
//  This example demonstrates the FluxObservation framework usage patterns.
//  FluxObservation backdeloys Apple's Observation framework to support earlier iOS versions.
//
//  Key demonstrations:
//  - Observable state objects using @Observable macro (backdeployed from iOS 17+)
//  - @ObservationTracking macro for automatic SwiftUI view updates (backdeployment feature)
//  - WithObservationTracking view wrapper for manual observation tracking (backdeployment feature)
//  - Environment injection of observable objects compatible with earlier iOS versions
//  - Reactive UI updates based on state changes across iOS versions
//

import FluxObservation
import SwiftUI

// Helper extension for easy visualization of View updates
extension View {
    func randomBackground() -> some View {
        self.background(
            Color(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1)
            )
        )
    }
}

@main
struct CounterApp: App {
    // Create the root observable state object
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainTabView()
                    // Inject the observable state into the environment using FluxObservation's
                    // custom environment extension that works with earlier iOS versions
                    .environment(appState)
            }
        }
    }
}

// Example of @Observable macro usage - backdeployed from iOS 17+ Observation framework
// The macro automatically generates observation infrastructure for earlier iOS versions
@Observable
public final class TimerState {
    // These properties automatically become observable when accessed in SwiftUI views
    public var seconds: Int = 0
    public var isRunning: Bool = false

    // @ObservationIgnored could be used here to prevent observation of private properties
    private var timer: Timer?

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Property mutations automatically trigger UI updates in observing views
            self.seconds += 1
        }
    }

    public func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    public func reset() {
        stop()
        seconds = 0
    }
}

@Observable
public final class CounterState {
    // Stored properties that will trigger UI updates when modified
    public var count: Int = 0
    public var step: Int = 1
    public var history: [Int] = []

    // Computed properties that depend on observable stored properties
    // These will automatically recompute when their dependencies change
    public var isEven: Bool {
        count % 2 == 0
    }

    public var isPrime: Bool {
        guard count > 1 else { return false }
        for i in 2..<count {
            if count % i == 0 {
                return false
            }
        }
        return true
    }

    // Methods that modify observable state will trigger UI updates
    public func increment() {
        history.append(count)
        count += step
    }

    public func decrement() {
        history.append(count)
        count -= step
    }

    public func reset() {
        history.append(count)
        count = 0
    }

    public func undo() {
        guard let lastValue = history.popLast() else { return }
        count = lastValue
    }
}

@Observable
public final class SettingsState {
    public var theme: Theme = .system
    public var animations: Bool = true
    public var notifications: Bool = true

    public enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
}

// Root observable state object demonstrating composition of multiple observable objects
@Observable
public final class AppState {
    // Nested observable objects maintain their reactivity
    public var counter = CounterState()
    public var timer = TimerState()
    public var settings = SettingsState()

    // Global state that can be observed across the app
    public var totalInteractions: Int = 0

    public func recordInteraction() {
        totalInteractions += 1
    }
}

// Example of @ObservationTracking macro usage - a backdeployment feature for automatic view updates
// This macro generates observation tracking code that works on earlier iOS versions
// It automatically wraps the view's body with observation tracking infrastructure
@ObservationTracking
struct MainTabView: View {
    // Using FluxObservation's custom Environment property wrapper for earlier iOS versions
    @FluxObservation.Environment var appState: AppState

    var body: some View {
        TabView {
            CounterTab()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Counter")
                }
                .randomBackground()

            TimerTab()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
                .randomBackground()

            SettingsTab()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .randomBackground()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // This text will automatically update when appState.totalInteractions changes
                // thanks to the @ObservationTracking macro above
                Text("Interactions: \(appState.totalInteractions)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .randomBackground()
            }
        }
    }
}

// Another example of @ObservationTracking macro for automatic observation
@ObservationTracking
struct CounterTab: View {
    // This demonstrates mixing FluxObservation with standard @EnvironmentObject
    // The @ObservationTracking macro ensures proper observation tracking
    @EnvironmentObject var appState: AppState

    // Computed property access to nested observable state
    private var counter: CounterState {
        appState.counter
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("\(counter.count)")
                        .font(.system(size: 72, weight: .light, design: .monospaced))
                        .foregroundColor(counter.isEven ? .blue : .red)
                        .animation(.easeInOut, value: counter.count)

                    HStack {
                        if counter.isEven {
                            Label("Even", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                        if counter.isPrime {
                            Label("Prime", systemImage: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.caption)
                }

                HStack(spacing: 20) {
                    Button {
                        counter.decrement()
                        appState.recordInteraction()
                    } label: {
                        Image(systemName: "minus")
                            .font(.title)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        counter.increment()
                        appState.recordInteraction()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                    .buttonStyle(.borderedProminent)
                }

                StepControlView()

                VStack {
                    HStack {
                        Button("Reset") {
                            counter.reset()
                            appState.recordInteraction()
                        }
                        .buttonStyle(.bordered)

                        Button("Undo") {
                            counter.undo()
                            appState.recordInteraction()
                        }
                        .buttonStyle(.bordered)
                        .disabled(counter.history.isEmpty)
                    }

                    if !counter.history.isEmpty {
                        Text("History: \(counter.history.suffix(5).map(String.init).joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Counter")
            .randomBackground()
        }
    }
}

// Example of manual observation tracking using WithObservationTracking view
// This is useful when you want fine-grained control over what gets observed
// or when you can't use the @ObservationTracking macro
struct StepControlView: View {
    @EnvironmentObject var appState: AppState

    private var counter: CounterState {
        appState.counter
    }

    var body: some View {
        // WithObservationTracking is a backdeployment utility view that manually wraps content
        // with observation tracking. This is an alternative to the @ObservationTracking macro
        WithObservationTracking {
            VStack {
                // This text will update when counter.step changes
                Text("Step: \(counter.step)")
                    .font(.headline)

                HStack {
                    Button("1") { counter.step = 1 }
                        .buttonStyle(.bordered)
                        .tint(counter.step == 1 ? .primary : .secondary)

                    Button("5") { counter.step = 5 }
                        .buttonStyle(.bordered)
                        .tint(counter.step == 5 ? .primary : .secondary)

                    Button("10") { counter.step = 10 }
                        .buttonStyle(.bordered)
                        .tint(counter.step == 10 ? .primary : .secondary)
                }
            }
        }
    }
}

@ObservationTracking
struct TimerTab: View {
    @EnvironmentObject var appState: AppState

    private var timer: TimerState {
        appState.timer
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                TimerDisplay()

                HStack(spacing: 20) {
                    if timer.isRunning {
                        Button("Stop") {
                            timer.stop()
                            appState.recordInteraction()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else {
                        Button("Start") {
                            timer.start()
                            appState.recordInteraction()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    Button("Reset") {
                        timer.reset()
                        appState.recordInteraction()
                    }
                    .buttonStyle(.bordered)
                    .disabled(timer.seconds == 0)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Timer")
            .randomBackground()
        }
    }
}

// Another example of WithObservationTracking for manual observation control
struct TimerDisplay: View {
    @EnvironmentObject var appState: AppState

    private var timer: TimerState {
        appState.timer
    }

    var body: some View {
        // Manual observation tracking allows this view to update when timer properties change
        WithObservationTracking {
            VStack {
                // Both timer.seconds and timer.isRunning are automatically observed
                Text(formatTime(timer.seconds))
                    .font(.system(size: 60, weight: .light, design: .monospaced))
                    .foregroundColor(timer.isRunning ? .green : .primary)

                Text(timer.isRunning ? "Running" : "Stopped")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

@ObservationTracking
struct SettingsTab: View {
    @EnvironmentObject var appState: AppState

    private var settings: SettingsState {
        appState.settings
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker(
                        "Theme",
                        selection: Binding(
                            get: { settings.theme },
                            set: { settings.theme = $0 }
                        )
                    ) {
                        ForEach(SettingsState.Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }

                Section("Behavior") {
                    Toggle(
                        "Animations",
                        isOn: Binding(
                            get: { settings.animations },
                            set: { settings.animations = $0 }
                        ))

                    Toggle(
                        "Notifications",
                        isOn: Binding(
                            get: { settings.notifications },
                            set: { settings.notifications = $0 }
                        ))
                }

                Section("Statistics") {
                    StatRowView(title: "Total Interactions", value: "\(appState.totalInteractions)")
                    StatRowView(title: "Counter Value", value: "\(appState.counter.count)")
                    StatRowView(title: "Timer Seconds", value: "\(appState.timer.seconds)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Final example showing WithObservationTracking for individual components
struct StatRowView: View {
    let title: String
    let value: String

    var body: some View {
        // Even small components can benefit from manual observation tracking
        // This ensures the value updates when the underlying observable state changes
        WithObservationTracking {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
