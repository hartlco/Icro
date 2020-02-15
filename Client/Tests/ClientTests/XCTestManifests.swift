import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ClientTests.allTests),
        testCase(HttpMethodTests.allTests),
    ]
}
#endif
