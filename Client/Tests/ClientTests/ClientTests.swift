import XCTest
@testable import Client

final class ClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }

    func testUnauthorizedResponseReportsHTTPStatus() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UnauthorizedURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let resource = Resource<[String: String]>(
            url: URL(string: "https://micro.blog/posts/timeline")!,
            authorization: nil,
            parseJSON: { $0 as? [String: String] }
        )

        do {
            _ = try await session.load(resource: resource)
            XCTFail("An unauthorized response must fail")
        } catch NetworkingError.httpStatus(let status) {
            XCTAssertEqual(status, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}

private final class UnauthorizedURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("Token required".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() { }
}
