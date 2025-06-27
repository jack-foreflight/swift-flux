//
//  DependencyResolutionTests.swift
//  swift-flux
//
//  Created by Jack Zhao on 6/26/25.
//

import XCTest
@testable import SwiftFlux

// MARK: - Test Environment Values

// ✅ No-parameter initializer
@AppEnvironmentValue
struct Logger {
    let level: String
    
    init() {
        self.level = "info"
    }
}

// ✅ Default parameter initializer  
@AppEnvironmentValue
struct APIService {
    let baseURL: String
    let timeout: TimeInterval
    
    init(baseURL: String = "https://api.example.com", timeout: TimeInterval = 30.0) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}

// ✅ Mixed parameters (dependency injection + defaults)
@AppEnvironmentValue
struct UserService {
    let apiService: APIService
    let logger: Logger
    let retryCount: Int
    
    init(apiService: APIService, logger: Logger, retryCount: Int = 3) {
        self.apiService = apiService
        self.logger = logger  
        self.retryCount = retryCount
    }
}

// ❌ Should fail - unresolvable parameter
// Commented out to avoid compilation errors in tests
/*
@AppEnvironmentValue  
struct DatabaseClient {
    let connectionString: String
    
    init(connectionString: String) {
        self.connectionString = connectionString
    }
}
*/

final class DependencyResolutionTests: XCTestCase {
    
    func testNoParameterInitializer() {
        // Test that Logger can be resolved with no-arg initializer
        let defaultLogger = Logger.defaultValue
        XCTAssertEqual(defaultLogger.level, "info")
    }
    
    func testDefaultParameterInitializer() {
        // Test that APIService uses default parameters
        let defaultService = APIService.defaultValue
        XCTAssertEqual(defaultService.baseURL, "https://api.example.com")
        XCTAssertEqual(defaultService.timeout, 30.0)
    }
    
    func testDependencyInjectionInitializer() {
        // Test that UserService resolves dependencies from environment
        let defaultService = UserService.defaultValue
        XCTAssertNotNil(defaultService.apiService)
        XCTAssertNotNil(defaultService.logger)
        XCTAssertEqual(defaultService.retryCount, 3) // default parameter
        
        // Verify the injected dependencies have correct default values
        XCTAssertEqual(defaultService.apiService.baseURL, "https://api.example.com")
        XCTAssertEqual(defaultService.logger.level, "info")
    }
    
    func testEnvironmentValueAccessors() {
        // Test direct AppEnvironmentKey access (convenience accessors commented out in macro)
        var env = AppEnvironmentValues()
        
        // Test Logger direct access
        let customLogger = Logger()
        env[Logger.self] = customLogger
        XCTAssertEqual(env[Logger.self].level, "info")
        
        // Test APIService direct access
        let customService = APIService(baseURL: "https://custom.api.com")
        env[APIService.self] = customService
        XCTAssertEqual(env[APIService.self].baseURL, "https://custom.api.com")
        
        // Test UserService direct access
        let customUserService = UserService(
            apiService: customService,
            logger: customLogger,
            retryCount: 5
        )
        env[UserService.self] = customUserService
        XCTAssertEqual(env[UserService.self].retryCount, 5)
    }
    
    func testEnvironmentValueInActions() async {
        // Test using environment values in actions
        let customLogger = Logger()
        let customService = APIService(baseURL: "https://test.api.com")
        
        await withEnvironment { env in
            env[Logger.self] = customLogger
            env[APIService.self] = customService
        } operation: {
            @AppEnvironment(Logger.self) var logger: Logger
            @AppEnvironment(APIService.self) var service: APIService
            @AppEnvironment(UserService.self) var userService: UserService
            
            XCTAssertEqual(logger.level, "info")
            XCTAssertEqual(service.baseURL, "https://test.api.com")
            XCTAssertEqual(userService.apiService.baseURL, "https://test.api.com")
        }
    }
}