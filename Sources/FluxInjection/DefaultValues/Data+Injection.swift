//
//  Data+Injection.swift
//  swift-flux
//
//  Default injection values for Data
//

import Foundation

public enum DataInjection: Injection {
    public static let defaultValue = Data()
}

extension InjectionValues {
    public var data: Data {
        get { self[DataInjection.self] }
        set { self[DataInjection.self] = newValue }
    }
}
