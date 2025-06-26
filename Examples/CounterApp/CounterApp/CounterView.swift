//
//  CounterView.swift
//  CounterApp - SwiftFlux Example
//
//  This view demonstrates the core counter functionality and shows
//  how to dispatch actions and react to state changes in SwiftUI.
//

import SwiftFlux
import SwiftUI
//
///// The main counter view that displays the counter value and controls.
///// This demonstrates how to build reactive UI with SwiftFlux.
//struct CounterView: View {
//    @Environment(Store<CounterAppState>.self) var store
//
//    /// We can create a focused view of just the counter state using a selector.
//    /// This demonstrates how to work with specific slices of state.
//    private var counterStore: SliceSelector<Store<CounterAppState>, CounterState> {
//        store.slice(\.counter)
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 30) {
//                // Header Section
//                headerSection
//
//                // Counter Display Section
//                counterDisplaySection
//
//                // Controls Section
//                controlsSection
//
//                // Step Size Section
//                stepSizeSection
//
//                Spacer()
//
//                // Action Buttons Section
//                actionButtonsSection
//            }
//            .padding()
//            .navigationTitle("SwiftFlux Counter")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Reset & Save") {
//                        // This demonstrates dispatching a composite async action
//                        Task {
//                            store.dispatch(ResetAndSaveAction())
//                        }
//                    }
//                    .disabled(store.state.loading.isSavingPreferences)
//                }
//            }
//        }
//    }
//
//    // MARK: - View Components
//
//    /// Header section with milestone celebration.
//    /// This demonstrates computed properties based on state.
//    private var headerSection: some View {
//        VStack {
//            if counterStore.state.hasReachedMilestone {
//                Text("🎉 Milestone Reached! 🎉")
//                    .font(.headline)
//                    .foregroundColor(.orange)
//                    .transition(.scale.combined(with: .opacity))
//            }
//
//            Text("Current Value")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .animation(.easeInOut, value: counterStore.state.hasReachedMilestone)
//    }
//
//    /// The main counter display.
//    /// This demonstrates how state automatically updates the UI.
//    private var counterDisplaySection: some View {
//        Text("\(counterStore.state.value)")
//            .font(.system(size: 72, weight: .bold, design: .rounded))
//            .foregroundColor(.primary)
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.blue.opacity(0.1))
//                    .stroke(Color.blue, lineWidth: 2)
//            )
//            // Animate value changes if animations are enabled
//            .animation(
//                store.state.preferences.animationsEnabled ? .easeInOut : nil,
//                value: counterStore.state.value
//            )
//    }
//
//    /// Main increment/decrement controls.
//    /// This demonstrates basic action dispatching.
//    private var controlsSection: some View {
//        HStack(spacing: 40) {
//            // Decrement Button
//            Button(action: {
//                store.dispatch(DecrementAction())
//                playSound()
//            }) {
//                Image(systemName: "minus.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.red)
//            }
//            .buttonStyle(PlainButtonStyle())
//
//            // Increment Button
//            Button(action: {
//                store.dispatch(IncrementAction())
//                playSound()
//            }) {
//                Image(systemName: "plus.circle.fill")
//                    .font(.system(size: 50))
//                    .foregroundColor(.green)
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//    }
//
//    /// Step size configuration section.
//    /// This demonstrates binding state to UI controls.
//    private var stepSizeSection: some View {
//        VStack {
//            Text("Step Size: \(counterStore.state.stepSize)")
//                .font(.headline)
//
//            HStack {
//                Button("1") { store.dispatch(SetStepSizeAction(stepSize: 1)) }
//                    .buttonStyle(.bordered)
//                    .foregroundColor(counterStore.state.stepSize == 1 ? .white : .blue)
//                    .background(counterStore.state.stepSize == 1 ? Color.blue : Color.clear)
//                    .cornerRadius(8)
//
//                Button("5") { store.dispatch(SetStepSizeAction(stepSize: 5)) }
//                    .buttonStyle(.bordered)
//                    .foregroundColor(counterStore.state.stepSize == 5 ? .white : .blue)
//                    .background(counterStore.state.stepSize == 5 ? Color.blue : Color.clear)
//                    .cornerRadius(8)
//
//                Button("10") { store.dispatch(SetStepSizeAction(stepSize: 10)) }
//                    .buttonStyle(.bordered)
//                    .foregroundColor(counterStore.state.stepSize == 10 ? .white : .blue)
//                    .background(counterStore.state.stepSize == 10 ? Color.blue : Color.clear)
//                    .cornerRadius(8)
//            }
//        }
//    }
//
//    /// Additional action buttons.
//    /// This demonstrates various action patterns.
//    private var actionButtonsSection: some View {
//        VStack(spacing: 16) {
//            // Reset button
//            Button("Reset Counter") {
//                store.dispatch(ResetCounterAction())
//                playSound()
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(counterStore.state.value == 0)
//
//            // Quick set buttons
//            HStack {
//                Button("Set to 100") {
//                    store.dispatch(SetCounterValueAction(newValue: 100))
//                }
//                .buttonStyle(.bordered)
//
//                Button("Set to -50") {
//                    store.dispatch(SetCounterValueAction(newValue: -50))
//                }
//                .buttonStyle(.bordered)
//            }
//
//            // History controls
//            HStack {
//                Button("View History") {
//                    store.dispatch(ToggleHistoryAction())
//                }
//                .buttonStyle(.bordered)
//                .disabled(counterStore.state.history.isEmpty)
//
//                Button("Clear History") {
//                    store.dispatch(ClearHistoryAction())
//                }
//                .buttonStyle(.bordered)
//                .disabled(counterStore.state.history.isEmpty)
//            }
//        }
//        // Present history sheet
//        .sheet(
//            isPresented: store.bind(\.navigation.isHistoryPresented, to: ToggleHistoryAction())
//        ) {
//            HistoryDetailView(store: store)
//        }
//    }
//
//    // MARK: - Helper Methods
//
//    /// Plays a sound if sound is enabled in preferences.
//    /// This demonstrates reading preferences from state.
//    private func playSound() {
//        if store.state.preferences.soundEnabled {
//            // In a real app, you would play an actual sound here
//            print("🔊 Playing sound effect")
//        }
//    }
//}
//
///// A detailed view for showing counter history.
///// This demonstrates modal presentation with SwiftFlux.
//struct HistoryDetailView: View {
//    var store: Store<CounterAppState>
//
//    var body: some View {
//        NavigationView {
//            List {
//                if store.state.counter.history.isEmpty {
//                    Text("No history available")
//                        .foregroundColor(.secondary)
//                        .italic()
//                } else {
//                    ForEach(Array(store.state.counter.history.enumerated()), id: \.offset) { index, value in
//                        HStack {
//                            Text("Step \(index + 1)")
//                                .foregroundColor(.secondary)
//                            Spacer()
//                            Text("\(value)")
//                                .font(.system(.body, design: .monospaced))
//                                .fontWeight(.semibold)
//                        }
//                        .padding(.vertical, 2)
//                    }
//                }
//            }
//            .navigationTitle("Counter History")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        store.dispatch(ToggleHistoryAction())
//                    }
//                }
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Clear") {
//                        store.dispatch(ClearHistoryAction())
//                    }
//                    .disabled(store.state.counter.history.isEmpty)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    CounterView()
//        .environment(Store(CounterAppState()))
//}
