import XCTest

@testable import FluxObservation

final class FluxObservationTests: XCTestCase {

    @Observable
    class TestModel {
        var name: String = "Initial"
        var count: Int = 0
    }

    func testBasicObservation() {
        let model = TestModel()
        withFluxObservationTracking {
            let result = model.name
        } onChange: {
            print("On Change")
        }

        // Test that model can be created and accessed
        XCTAssertEqual(model.name, "Initial")
        XCTAssertEqual(model.count, 0)

        // Test that properties can be modified
        model.name = "Changed"

        model.count = 42

        XCTAssertEqual(model.name, "Changed")
        XCTAssertEqual(model.count, 42)
    }
}
