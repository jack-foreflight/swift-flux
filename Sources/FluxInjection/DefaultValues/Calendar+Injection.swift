//
//  Calendar+Injection.swift
//  swift-flux
//
//  Default injection values for Calendar
//

import Foundation

public enum CalendarInjection: Injection {
    public static var defaultValue: Calendar { Calendar.autoupdatingCurrent }
}

extension InjectionValues {
    public var calendar: Calendar {
        get { self[CalendarInjection.self] }
        set { self[CalendarInjection.self] = newValue }
    }
}
