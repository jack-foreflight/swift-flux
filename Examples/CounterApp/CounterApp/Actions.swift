//
//  Actions.swift
//  CounterApp - SwiftFlux Example
//
//  This file demonstrates how to define actions in SwiftFlux.
//  Actions are the only way to modify state in the Flux architecture.
//

import Foundation
import SwiftFlux

// MARK: - Counter Actions
//
///// Increments the counter by the current step size.
///// This demonstrates a simple synchronous action.
//struct IncrementAction: Action, LoggableAction {
//    typealias State = CounterState
//    
//    func operation(state: CounterState) {
//        // Add current value to history before changing it
//        state.history.append(state.value)
//        
//        // Keep history to a reasonable size
//        if state.history.count > 10 {
//            state.history.removeFirst()
//        }
//        
//        // Increment the counter
//        state.value += state.stepSize
//    }
//}
//
///// Decrements the counter by the current step size.
///// This demonstrates another simple synchronous action.
//struct DecrementAction: Action, LoggableAction {
//    typealias State = CounterState
//    
//    func operation(state: CounterState) {
//        // Add current value to history before changing it
//        state.history.append(state.value)
//        
//        // Keep history to a reasonable size
//        if state.history.count > 10 {
//            state.history.removeFirst()
//        }
//        
//        // Decrement the counter
//        state.value -= state.stepSize
//    }
//}
//
///// Resets the counter to zero.
///// This demonstrates an action that performs multiple state changes.
//struct ResetCounterAction: Action, LoggableAction {
//    typealias State = CounterState
//    
//    func operation(state: CounterState) {
//        // Save current value to history if it's not already zero
//        if state.value != 0 {
//            state.history.append(state.value)
//            
//            // Keep history to a reasonable size
//            if state.history.count > 10 {
//                state.history.removeFirst()
//            }
//        }
//        
//        // Reset the counter
//        state.value = 0
//    }
//}
//
///// Sets the counter to a specific value.
///// This demonstrates an action with parameters.
//struct SetCounterValueAction: Action, LoggableAction {
//    typealias State = CounterState
//    
//    let newValue: Int
//    
//    func operation(state: CounterState) {
//        // Add current value to history before changing it
//        if state.value != newValue {
//            state.history.append(state.value)
//            
//            // Keep history to a reasonable size
//            if state.history.count > 10 {
//                state.history.removeFirst()
//            }
//        }
//        
//        // Set the new value
//        state.value = newValue
//    }
//}
//
///// Changes the step size for increment/decrement operations.
///// This demonstrates modifying a configuration value.
//struct SetStepSizeAction: Action {
//    typealias State = CounterState
//    
//    let stepSize: Int
//    
//    func operation(state: CounterState) {
//        state.stepSize = max(1, stepSize) // Ensure step size is at least 1
//    }
//}
//
///// Clears the counter history.
///// This demonstrates an action that modifies array state.
//struct ClearHistoryAction: Action {
//    typealias State = CounterState
//    
//    func operation(state: CounterState) {
//        state.history.removeAll()
//    }
//}
//
//// MARK: - Navigation Actions
//
///// Changes the selected tab.
///// This demonstrates navigation state management.
//struct SelectTabAction: Action {
//    typealias State = NavigationState
//    
//    let tab: AppTab
//    
//    func operation(state: NavigationState) {
//        state.selectedTab = tab
//    }
//}
//
///// Toggles the settings sheet presentation.
///// This demonstrates boolean state management.
//struct ToggleSettingsAction: Action {
//    typealias State = NavigationState
//    
//    func operation(state: NavigationState) {
//        state.isSettingsPresented.toggle()
//    }
//}
//
///// Toggles the history sheet presentation.
///// This demonstrates another boolean state toggle.
//struct ToggleHistoryAction: Action {
//    typealias State = NavigationState
//    
//    func operation(state: NavigationState) {
//        state.isHistoryPresented.toggle()
//    }
//}
//
//// MARK: - Preferences Actions
//
///// Toggles animation preferences.
///// This demonstrates simple preference management.
//struct ToggleAnimationsAction: Action {
//    typealias State = PreferencesState
//    
//    func operation(state: PreferencesState) {
//        state.animationsEnabled.toggle()
//    }
//}
//
///// Toggles sound preferences.
///// This demonstrates another preference toggle.
//struct ToggleSoundAction: Action {
//    typealias State = PreferencesState
//    
//    func operation(state: PreferencesState) {
//        state.soundEnabled.toggle()
//    }
//}
//
///// Changes the app theme.
///// This demonstrates enum-based state management.
//struct SetThemeAction: Action {
//    typealias State = PreferencesState
//    
//    let theme: Theme
//    
//    func operation(state: PreferencesState) {
//        state.theme = theme
//    }
//}
//
///// Sets the maximum number of history items.
///// This demonstrates numeric preference management.
//struct SetMaxHistoryItemsAction: Action {
//    typealias State = PreferencesState
//    
//    let maxItems: Int
//    
//    func operation(state: PreferencesState) {
//        state.maxHistoryItems = max(5, min(50, maxItems)) // Keep between 5 and 50
//    }
//}
//
//// MARK: - Async Actions
//
///// Saves preferences to persistent storage.
///// This demonstrates an asynchronous action with error handling using the simplified AsyncAction interface.
//struct SavePreferencesAction: AsyncAction, CancellableAction {
//    typealias State = CounterAppState
//    
//    func operation(store: Store<CounterAppState>) async {
//        // Set loading state
//        await store.dispatch(SetLoadingAction(isLoading: true, operation: "savingPreferences"))
//        
//        do {
//            // Simulate network/storage delay
//            try await Task.sleep(for: .seconds(1))
//            
//            // Simulate potential failure (20% chance)
//            if Bool.random() && Int.random(in: 1...5) == 1 {
//                throw SaveError.networkUnavailable
//            }
//            
//            // In a real app, you would save to UserDefaults, Core Data, etc.
//            print("Preferences saved successfully")
//            
//            // Clear any previous errors
//            await store.dispatch(ClearErrorAction())
//            
//        } catch {
//            await failed(error: error, store: store)
//        }
//        
//        // Clear loading state
//        await store.dispatch(SetLoadingAction(isLoading: false, operation: "savingPreferences"))
//    }
//    
//    func failed(error: any Error, store: Store<CounterAppState>) async {
//        await store.dispatch(SetErrorAction(message: "Failed to save preferences: \(error.localizedDescription)"))
//    }
//}
//
///// Loads saved data from persistent storage.
///// This demonstrates another async action pattern with the simplified interface.
//struct LoadDataAction: AsyncAction, CancellableAction {
//    typealias State = CounterAppState
//    
//    func operation(store: Store<CounterAppState>) async {
//        // Set loading state
//        await store.dispatch(SetLoadingAction(isLoading: true, operation: "loadingData"))
//        
//        do {
//            // Simulate loading delay
//            try await Task.sleep(for: .milliseconds(500))
//            
//            // In a real app, you would load from UserDefaults, Core Data, etc.
//            let savedCounterValue = UserDefaults.standard.integer(forKey: "counterValue")
//            if savedCounterValue != 0 {
//                await store.dispatch(SetCounterValueAction(newValue: savedCounterValue))
//            }
//            
//            // Clear any previous errors
//            await store.dispatch(ClearErrorAction())
//            
//        } catch {
//            await failed(error: error, store: store)
//        }
//        
//        // Clear loading state
//        await store.dispatch(SetLoadingAction(isLoading: false, operation: "loadingData"))
//    }
//    
//    func failed(error: any Error, store: Store<CounterAppState>) async {
//        await store.dispatch(SetErrorAction(message: "Failed to load data: \(error.localizedDescription)"))
//    }
//}
//
//// MARK: - Loading State Actions
//
///// Sets a loading state for a specific operation.
///// This demonstrates managing loading states for different operations.
//struct SetLoadingAction: Action {
//    typealias State = LoadingState
//    
//    let isLoading: Bool
//    let operation: String
//    
//    func operation(state: LoadingState) {
//        switch operation {
//        case "savingPreferences":
//            state.isSavingPreferences = isLoading
//        case "loadingData":
//            state.isLoadingData = isLoading
//        default:
//            break
//        }
//    }
//}
//
///// Sets an error message in the loading state.
///// This demonstrates error state management.
//struct SetErrorAction: Action {
//    typealias State = LoadingState
//    
//    let message: String
//    
//    func operation(state: LoadingState) {
//        state.lastError = message
//    }
//}
//
///// Clears any error message.
///// This demonstrates clearing error state.
//struct ClearErrorAction: Action {
//    typealias State = LoadingState
//    
//    func operation(state: LoadingState) {
//        state.lastError = nil
//    }
//}
//
//// MARK: - Composite Actions
//
///// Performs a complete counter reset with preferences save.
///// This demonstrates how to compose multiple actions together using ActionBuilder.
//struct ResetAndSaveAction: AsyncAction {
//    typealias State = CounterAppState
//    
//    func operation(store: Store<CounterAppState>) async {
//        // First reset the counter
//        await store.dispatch(ResetCounterAction())
//        
//        // Then clear the history
//        await store.dispatch(ClearHistoryAction())
//        
//        // Finally save preferences
//        await store.dispatch(SavePreferencesAction())
//    }
//}
//
//// MARK: - Custom Errors
//
//enum SaveError: Error, LocalizedError {
//    case networkUnavailable
//    case diskFull
//    case permissionDenied
//    
//    var errorDescription: String? {
//        switch self {
//        case .networkUnavailable:
//            return "Network is unavailable"
//        case .diskFull:
//            return "Disk is full"
//        case .permissionDenied:
//            return "Permission denied"
//        }
//    }
//}
