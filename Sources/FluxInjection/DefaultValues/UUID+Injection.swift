//
//  UUID+Injection.swift
//  swift-flux
//
//  Default injection values for UUID
//

import Foundation

public enum UUIDInjection: Injection {
    public static let defaultValue = UUID()
}

extension InjectionValues {
    public var uuid: UUID {
        get { self[UUIDInjection.self] }
        set { self[UUIDInjection.self] = newValue }
    }
}
