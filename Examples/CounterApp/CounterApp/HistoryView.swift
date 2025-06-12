//
//  HistoryView.swift
//  CounterApp - SwiftFlux Example
//
//  This view demonstrates how to display historical data from the store
//  and shows different ways to interact with array-based state.
//

import SwiftUI
import SwiftFlux

/// A view that displays the counter history in a more detailed format.
/// This demonstrates working with collection state in SwiftFlux.
struct HistoryView: View {
    var store: Store<CounterAppState>
    
    var body: some View {
        NavigationView {
            VStack {
                if store.state.counter.history.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear History") {
                            store.dispatch(ClearHistoryAction())
                        }
                        .disabled(store.state.counter.history.isEmpty)
                        
                        Button("Export History") {
                            exportHistory()
                        }
                        .disabled(store.state.counter.history.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    /// Empty state view when no history is available.
    /// This demonstrates conditional UI based on state.
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start using the counter to build up your history!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Go to Counter") {
                store.dispatch(SelectTabAction(tab: .counter))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    /// List view showing the history items.
    /// This demonstrates displaying collection data from state.
    private var historyListView: some View {
        VStack {
            // Summary Section
            historySummaryView
            
            // History List
            List {
                ForEach(Array(store.state.counter.history.enumerated().reversed()), id: \.offset) { index, value in
                    HistoryRowView(
                        stepNumber: store.state.counter.history.count - index,
                        value: value,
                        isLatest: index == 0,
                        store: store
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    /// Summary view showing statistics about the history.
    /// This demonstrates computed properties from state.
    private var historySummaryView: some View {
        VStack(spacing: 12) {
            Text("History Statistics")
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 30) {
                StatisticView(
                    title: "Total Steps",
                    value: "\(store.state.counter.history.count)"
                )
                
                StatisticView(
                    title: "Highest",
                    value: "\(store.state.counter.history.max() ?? 0)"
                )
                
                StatisticView(
                    title: "Lowest",
                    value: "\(store.state.counter.history.min() ?? 0)"
                )
            }
            
            Divider()
                .padding(.horizontal)
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Methods
    
    /// Exports the history (simulated).
    /// This demonstrates how you might handle data export in a real app.
    private func exportHistory() {
        let historyText = store.state.counter.history
            .enumerated()
            .map { "Step \($0.offset + 1): \($0.element)" }
            .joined(separator: "\n")
        
        print("Exported History:\n\(historyText)")
        
        // In a real app, you might:
        // - Save to Files app
        // - Share via activity sheet
        // - Copy to clipboard
    }
}

/// A view that displays a single statistic.
/// This demonstrates reusable components that work with SwiftFlux state.
struct StatisticView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// A view that displays a single history row.
/// This demonstrates component composition with SwiftFlux.
struct HistoryRowView: View {
    let stepNumber: Int
    let value: Int
    let isLatest: Bool
    
    var store: Store<CounterAppState>
    
    var body: some View {
        HStack {
            // Step indicator
            ZStack {
                Circle()
                    .fill(isLatest ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                
                Text("\(stepNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isLatest ? .white : .primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(stepNumber)")
                    .font(.headline)
                
                Text("Value: \(value)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action button to restore this value
            Button("Restore") {
                store.dispatch(SetCounterValueAction(newValue: value))
                store.dispatch(SelectTabAction(tab: .counter))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
        .background(isLatest ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    // Create a store with some sample history for preview
    let sampleStore = Store(CounterAppState())
    sampleStore.state.counter.history = [0, 5, 10, 8, 15, 20]
    
    return HistoryView(store: sampleStore)
}
