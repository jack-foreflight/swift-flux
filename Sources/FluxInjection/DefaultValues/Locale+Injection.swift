//
//  Locale+Injection.swift
//  swift-flux
//
//  Default injection values for Locale
//

import Foundation

public enum LocaleInjection: Injection {
    public static var defaultValue: Locale { Locale.autoupdatingCurrent }
}

extension InjectionValues {
    public var locale: Locale {
        get { self[LocaleInjection.self] }
        set { self[LocaleInjection.self] = newValue }
    }
}
