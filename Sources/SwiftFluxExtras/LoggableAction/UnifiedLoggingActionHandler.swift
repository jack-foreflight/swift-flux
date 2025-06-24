//
//  UnifiedLoggingActionHandler.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/20/25.
//

import Foundation
import OSLog

public struct UnifiedLoggingActionHandler<Action: LoggableAction>: Handler {
    private let logger: Logger

    public init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func willPerform(action: Action) {
        logger.info("")
    }

    public func didPerform(action: Action) {
        logger.info("")
    }

    public func didFail(action: Action, failure: any Error) {
        logger.error("")
    }
}
