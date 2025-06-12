//
//  SettingsView.swift
//  CounterApp - SwiftFlux Example
//
//  This view demonstrates how to manage user preferences using SwiftFlux
//  and shows different types of preference controls.
//

import SwiftFlux
import SwiftUI

/// A view for managing app settings and preferences.
/// This demonstrates preference management with SwiftFlux.
struct SettingsView: View {
    @Environment(Store<CounterAppState>.self) var store

    var body: some View {
        NavigationView {
            Form {
                // App Preferences Section
                appPreferencesSection

                // Counter Settings Section
                counterSettingsSection

                // Data Management Section
                dataManagementSection

                // About Section
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.dispatch(SavePreferencesAction())
                    }
                    .disabled(store.state.loading.isSavingPreferences)
                }
            }
        }
    }

    // MARK: - View Sections

    /// App-wide preferences section.
    /// This demonstrates toggle controls with SwiftFlux state.
    private var appPreferencesSection: some View {
        Section("App Preferences") {
            // Animations toggle
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.orange)
                    .frame(width: 20)

                Toggle(
                    "Enable Animations",
                    isOn: Binding<Bool>(
                        get: { store.state.preferences.animationsEnabled },
                        set: { _ in store.dispatch(ToggleAnimationsAction()) }
                    ))
            }

            // Sound toggle
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)

                Toggle(
                    "Enable Sound",
                    isOn: Binding<Bool>(
                        get: { store.state.preferences.soundEnabled },
                        set: { _ in store.dispatch(ToggleSoundAction()) }
                    ))
            }

            // Theme picker
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.purple)
                    .frame(width: 20)

                Picker(
                    "Theme",
                    selection: Binding<Theme>(
                        get: { store.state.preferences.theme },
                        set: { newTheme in store.dispatch(SetThemeAction(theme: newTheme)) }
                    )
                ) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
            }
        }
    }

    /// Counter-specific settings section.
    /// This demonstrates stepper controls and number formatting.
    private var counterSettingsSection: some View {
        Section("Counter Settings") {
            // Current counter value (read-only display)
            HStack {
                Image(systemName: "number")
                    .foregroundColor(.green)
                    .frame(width: 20)

                Text("Current Value")
                Spacer()
                Text("\(store.state.counter.value)")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .monospaced))
            }

            // Step size setting
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.red)
                    .frame(width: 20)

                Text("Step Size")
                Spacer()
                Stepper(
                    value: Binding<Int>(
                        get: { store.state.counter.stepSize },
                        set: { newValue in store.dispatch(SetStepSizeAction(stepSize: newValue)) }
                    ),
                    in: 1...100
                ) {
                    Text("\(store.state.counter.stepSize)")
                        .font(.system(.body, design: .monospaced))
                }
            }

            // Max history items setting
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.orange)
                    .frame(width: 20)

                VStack(alignment: .leading) {
                    Text("Max History Items")
                    Text("Currently storing \(store.state.counter.history.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Stepper(
                    value: Binding<Int>(
                        get: { store.state.preferences.maxHistoryItems },
                        set: { newValue in store.dispatch(SetMaxHistoryItemsAction(maxItems: newValue)) }
                    ),
                    in: 5...50
                ) {
                    Text("\(store.state.preferences.maxHistoryItems)")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
    }

    /// Data management section.
    /// This demonstrates async actions with loading states.
    private var dataManagementSection: some View {
        Section("Data Management") {
            // Save preferences button
            Button(action: {
                store.dispatch(SavePreferencesAction())
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.blue)
                        .frame(width: 20)

                    Text("Save Preferences")

                    Spacer()

                    if store.state.loading.isSavingPreferences {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .disabled(store.state.loading.isSavingPreferences)

            // Load data button
            Button(action: {
                store.dispatch(LoadDataAction())
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.green)
                        .frame(width: 20)

                    Text("Load Saved Data")

                    Spacer()

                    if store.state.loading.isLoadingData {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .disabled(store.state.loading.isLoadingData)

            // Reset everything button
            Button(action: {
                store.dispatch(ResetAndSaveAction())
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.red)
                        .frame(width: 20)

                    Text("Reset Everything")

                    Spacer()

                    if store.state.loading.isSavingPreferences {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .disabled(store.state.loading.isSavingPreferences)
        }
    }

    /// About section with app information.
    /// This demonstrates displaying static information alongside dynamic state.
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .frame(width: 20)

                VStack(alignment: .leading) {
                    Text("SwiftFlux Counter Example")
                        .font(.headline)
                    Text("Demonstrates SwiftFlux architecture patterns")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Image(systemName: "number")
                    .foregroundColor(.green)
                    .frame(width: 20)

                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            // State debugging information
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 8) {
                    StateDebugRow(label: "Counter Value", value: "\(store.state.counter.value)")
                    StateDebugRow(label: "Step Size", value: "\(store.state.counter.stepSize)")
                    StateDebugRow(label: "History Count", value: "\(store.state.counter.history.count)")
                    StateDebugRow(label: "Animations", value: "\(store.state.preferences.animationsEnabled)")
                    StateDebugRow(label: "Sound", value: "\(store.state.preferences.soundEnabled)")
                    StateDebugRow(label: "Theme", value: store.state.preferences.theme.rawValue)
                    StateDebugRow(label: "Current Tab", value: store.state.navigation.selectedTab.rawValue)
                    StateDebugRow(label: "Is Saving", value: "\(store.state.loading.isSavingPreferences)")
                    StateDebugRow(label: "Is Loading", value: "\(store.state.loading.isLoadingData)")
                }
                .padding(.vertical, 8)
            } label: {
                HStack {
                    Image(systemName: "ladybug")
                        .foregroundColor(.red)
                        .frame(width: 20)

                    Text("Debug State")
                }
            }
        }
    }
}

/// A helper view for displaying debug state information.
/// This demonstrates how to create reusable components for debugging.
struct StateDebugRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView().environment(Store(CounterAppState()))
}
