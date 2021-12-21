//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import Client

final class MockClient<B: Codable>: Client {
    private let returnedData: Data?
    private let returnedResourceResult: Result<B, Error>?

    init(returnedData: Data?,
         returnedResourceResult: Result<B, Error>?) {
        self.returnedData = returnedData
        self.returnedResourceResult = returnedResourceResult
    }

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let returnedData = returnedData else {
            fatalError("Return Data not set")
        }

        return (returnedData, URLResponse(
            url: request.url!,
            mimeType: "",
            expectedContentLength: 0,
            textEncodingName: "")
        )
    }

    var error: Error?
    func load<A>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) where A: Decodable, A: Encodable {
        if let error = error {
            completion(.failure(error))
        }

        guard let result = returnedResourceResult as? Result<A, Error> else { return }
        completion(result)
    }

    func load<A: Codable>(resource: Resource<A>) async throws -> A {
        fatalError("Not implemented")
    }
}
