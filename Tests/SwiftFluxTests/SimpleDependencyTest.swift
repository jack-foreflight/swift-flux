//
//  SimpleDependencyTest.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import XCTest
@testable import SwiftFlux

// Simple test environment values
@AppEnvironmentValue
struct SimpleLogger {
    let level: String
    
    init() {
        self.level = "debug"
    }
}

@AppEnvironmentValue
struct SimpleClient {
    let url: String
    
    init(url: String = "https://default.com") {
        self.url = url
    }
}

final class SimpleDependencyTest: XCTestCase {
    
    func testNoParameterInitializer() {
        let logger = SimpleLogger.defaultValue
        XCTAssertEqual(logger.level, "debug")
    }
    
    func testDefaultParameterInitializer() {
        let client = SimpleClient.defaultValue
        XCTAssertEqual(client.url, "https://default.com")
    }
    
    func testEnvironmentKeyConformance() {
        // Test that the macro generated AppEnvironmentKey conformance
        // We can verify this by checking that defaultValue is accessible
        XCTAssertNotNil(SimpleLogger.defaultValue)
        XCTAssertNotNil(SimpleClient.defaultValue)
    }
    
    func testEnvironmentAccess() {
        var env = AppEnvironmentValues()
        
        // Test direct key access
        let customLogger = SimpleLogger()
        env[SimpleLogger.self] = customLogger
        XCTAssertEqual(env[SimpleLogger.self].level, "debug")
        
        // Test with custom client
        let customClient = SimpleClient(url: "https://test.com")
        env[SimpleClient.self] = customClient
        XCTAssertEqual(env[SimpleClient.self].url, "https://test.com")
    }
}