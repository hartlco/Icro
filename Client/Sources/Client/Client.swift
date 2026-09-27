//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

public protocol Client {
    func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void)

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func load<A: Codable>(resource: Resource<A>) async throws -> A

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: Client {
    public func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) {
        dataTask(with: resource.urlRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                DispatchQueue.main.async { completion(.failure(NetworkingError.httpStatus(response.statusCode))) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkingError.cannotParse))
                }
                return
            }

            let finalData = resource.parse(data)
            DispatchQueue.main.async {
                completion(finalData)
            }
        }.resume()
    }

    @available(macOS 12.0, *)
    @available(iOS 15.0, *)
    public func load<A: Codable>(resource: Resource<A>) async throws -> A {
        let (data, response) = try await data(for: resource.urlRequest, delegate: nil)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw NetworkingError.httpStatus(response.statusCode)
        }
        let parsedData = resource.parse(data)

        switch parsedData {
        case .failure(let error):
            throw error
        case .success(let data):
            return data
        }
    }
}

public struct Resource<A> {
    private(set) public var urlRequest: URLRequest
    let parse: (Data) -> Result<A, Error>
}

public enum NetworkingError: Error {
    case cannotParse
    case httpStatus(Int)
    case generalError(error: Error)
    case invalidInput
}

extension Result {
    public var value: Success? {
        switch self {
        case .failure:
            return nil
        case .success(let value):
            return value
        }
    }

    public init(value: Success?, error: Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
}

public enum HttpAuthoriztation {
    case bearer(token: String)
    case plain(token: String)
}

public extension Resource {
    init(url: URL, httpMethod: HttpMethod = .get,
         authorization: HttpAuthoriztation?,
         contentType: String? = nil,
         parseJSON: @escaping (Any) -> A?) {
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = httpMethod.method
        if let contentType = contentType {
            self.urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        switch authorization {
        case .some(.bearer(let token)):
            self.urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .some(.plain(let token)):
            self.urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        case .none:
            break
        }

        switch httpMethod {
        case .get, .delete: ()
        case .post(let body):
            self.urlRequest.httpBody = body
        }

        self.parse = { data in
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) ?? NSNull()

            return Result(value: parseJSON(json), error: NetworkingError.cannotParse)
        }
    }
}
