import XCTest
@testable import PrismBased

final class PrismBasedTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ZeplinBased().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
