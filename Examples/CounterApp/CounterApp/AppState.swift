//
//  AppState.swift
//  CounterApp - SwiftFlux Example
//
//  This file demonstrates how to define application state using SwiftFlux.
//  The @AppState macro automatically implements Observable and AppState protocols.
//

import Foundation
import SwiftFlux
//
//// MARK: - Root Application State
//
///// The root state of our counter application.
///// This demonstrates how to organize state in a SwiftFlux application.
//@AppState
//class CounterAppState {
//    /// The main counter state - automatically registered due to @AppState macro
//    var counter = CounterState()
//    
//    /// User preferences state - demonstrates nested state management
//    var preferences = PreferencesState()
//    
//    /// Navigation state for managing app navigation
//    var navigation = NavigationState()
//    
//    /// Loading states for async operations
//    var loading = LoadingState()
//}
//
//// MARK: - Counter State
//
///// State for the counter feature.
///// This demonstrates a simple piece of state with a numeric value.
//@AppState
//class CounterState {
//    /// The current counter value
//    var value: Int = 0
//    
//    /// The step size for increment/decrement operations
//    var stepSize: Int = 1
//    
//    /// History of counter values (last 10 values)
//    var history: [Int] = []
//    
//    /// Whether the counter has reached a milestone (every 10)
//    var hasReachedMilestone: Bool {
//        value % 10 == 0 && value > 0
//    }
//}
//
//// MARK: - Preferences State
//
///// State for user preferences.
///// This demonstrates how to manage user settings in SwiftFlux.
//@AppState
//class PreferencesState {
//    /// Whether to show animations
//    var animationsEnabled: Bool = true
//    
//    /// Whether to play sounds
//    var soundEnabled: Bool = true
//    
//    /// The user's preferred theme
//    var theme: Theme = .system
//    
//    /// Maximum number of history items to keep
//    var maxHistoryItems: Int = 10
//}
//
///// Available app themes
//enum Theme: String, CaseIterable {
//    case light = "Light"
//    case dark = "Dark"
//    case system = "System"
//}
//
//// MARK: - Navigation State
//
///// State for managing navigation within the app.
///// This demonstrates how to handle navigation state in SwiftFlux.
//@AppState
//class NavigationState {
//    /// Currently selected tab
//    var selectedTab: AppTab = .counter
//    
//    /// Whether the settings sheet is presented
//    var isSettingsPresented: Bool = false
//    
//    /// Whether the history sheet is presented
//    var isHistoryPresented: Bool = false
//}
//
///// Available app tabs
//enum AppTab: String, CaseIterable {
//    case counter = "Counter"
//    case history = "History"
//    case settings = "Settings"
//}
//
//// MARK: - Loading State
//
///// State for managing loading states of async operations.
///// This demonstrates how to handle async state in SwiftFlux.
//@AppState
//class LoadingState {
//    /// Whether we're currently saving preferences
//    var isSavingPreferences: Bool = false
//    
//    /// Whether we're loading saved data
//    var isLoadingData: Bool = false
//    
//    /// Any error that occurred during async operations
//    var lastError: String? = nil
//}
