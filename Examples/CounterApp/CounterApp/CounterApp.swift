//
//  CounterApp.swift
//  CounterApp - SwiftFlux Example
//
//

import FluxObservation
import SwiftUI

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
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainTabView()
                    .environment(appState)
            }
        }
    }
}

@Observable
public final class TimerState {
    public var seconds: Int = 0
    public var isRunning: Bool = false
    private var timer: Timer?

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
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
    public var count: Int = 0
    public var step: Int = 1
    public var history: [Int] = []

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

@Observable
public final class AppState {
    public var counter = CounterState()
    public var timer = TimerState()
    public var settings = SettingsState()

    public var totalInteractions: Int = 0

    public func recordInteraction() {
        totalInteractions += 1
    }
}

@ObservationTracking
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            CounterTab()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Counter")
                }

            TimerTab()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }

            SettingsTab()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Interactions: \(appState.totalInteractions)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@ObservationTracking
struct CounterTab: View {
    @EnvironmentObject var appState: AppState

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
        }
    }
}

struct StepControlView: View {
    @EnvironmentObject var appState: AppState

    private var counter: CounterState {
        appState.counter
    }

    var body: some View {
        WithObservationTracking {
            VStack {
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
        }
    }
}

struct TimerDisplay: View {
    @EnvironmentObject var appState: AppState

    private var timer: TimerState {
        appState.timer
    }

    var body: some View {
        WithObservationTracking {
            VStack {
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

struct StatRowView: View {
    let title: String
    let value: String

    var body: some View {
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
