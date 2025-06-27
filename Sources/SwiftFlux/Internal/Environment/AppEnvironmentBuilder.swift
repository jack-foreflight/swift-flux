//
//  AppEnvironmentBuilder.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import Foundation

@resultBuilder
public struct AppEnvironmentBuilder {
    public static func buildBlock<Key: AppEnvironmentKey>(_ values: Key.Value...) -> [(Key, Key.Value)] {
        //        Parallel(actions)
        fatalError()
    }

    //    public static func buildOptional(_ actions: [any Action]?) -> Self {
    //        Parallel(actions ?? [])
    //    }
    //
    //    public static func buildEither(first actions: [any Action]) -> Self {
    //        Parallel(actions)
    //    }
    //
    //    public static func buildEither(second actions: [any Action]) -> Self {
    //        Parallel(actions)
    //    }
    //
    //    public static func buildArray(_ actions: [[any Action]]) -> Self {
    //        Parallel(actions.flatMap { $0 })
    //    }
}
