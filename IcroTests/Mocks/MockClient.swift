//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
@testable import IcroKit

final class MockClient<B: Codable>: Client {
    private let returnedData: Data?
    private let returnedResourceResult: Result<B, Error>?

    init(returnedData: Data?,
         returnedResourceResult: Result<B, Error>?) {
        self.returnedData = returnedData
        self.returnedResourceResult = returnedResourceResult
    }

    func loadData(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completionHandler(returnedData, nil, nil)
    }

    var error: Error?
    func load<A>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) where A: Decodable, A: Encodable {
        if let error = error {
            completion(.failure(error))
        }

        guard let result = returnedResourceResult as? Result<A, Error> else { return }
        completion(result)
    }
}
