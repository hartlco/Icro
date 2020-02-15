import XCTest
@testable import Client

final class HttpMethodTests: XCTestCase {
    func test_method_isCorrectForGet() {
        XCTAssert(HttpMethod.get.method == "GET")
    }

    func test_method_isCorrectForPost() {
        XCTAssert(HttpMethod.post(nil).method == "POST")
    }

    func test_method_isCorrectForDelete() {
        XCTAssert(HttpMethod.delete.method == "DELETE")
    }

    static var allTests = [
        ("test_method_isCorrectForGet", test_method_isCorrectForGet,
         "test_method_isCorrectForPost", test_method_isCorrectForPost,
         "test_method_isCorrectForDelete", test_method_isCorrectForDelete)
    ]
}
