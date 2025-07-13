//
//  Date+Injection.swift
//  swift-flux
//
//  Default injection values for Date
//

import Foundation

public enum DateInjection: Injection {
    public static var defaultValue: Date { Date() }
}

extension InjectionValues {
    public var date: Date {
        get { self[DateInjection.self] }
        set { self[DateInjection.self] = newValue }
    }
}
