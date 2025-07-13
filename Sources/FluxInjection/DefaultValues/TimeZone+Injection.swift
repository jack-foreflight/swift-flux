//
//  TimeZone+Injection.swift
//  swift-flux
//
//  Default injection values for TimeZone
//

import Foundation

public enum TimeZoneInjection: Injection {
    public static var defaultValue: TimeZone { TimeZone.autoupdatingCurrent }
}

extension InjectionValues {
    public var timeZone: TimeZone {
        get { self[TimeZoneInjection.self] }
        set { self[TimeZoneInjection.self] = newValue }
    }
}
