import XCTest
@testable import Settings

final class SettingsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Settings().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
