//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

public protocol Client {
    func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A>) -> Void)
    func loadData(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: Client {
    public func loadData(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }

    public func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A>) -> Void) {
        dataTask(with: resource.urlRequest) { (data, _, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.error(error: NetworkingError.cannotParse))
                }
                return
            }

            let finalData = resource.parse(data)
            DispatchQueue.main.async {
                completion(finalData)
            }
        }.resume()
    }
}
