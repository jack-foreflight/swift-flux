//
//  URL+Injection.swift
//  swift-flux
//
//  Default injection values for URL
//

import Foundation

public enum URLSessionInjection: Injection {
    public static let defaultValue = URLSession(configuration: .default)
}

extension InjectionValues {
    public var url: URLSession {
        get { self[URLSessionInjection.self] }
        set { self[URLSessionInjection.self] = newValue }
    }
}
