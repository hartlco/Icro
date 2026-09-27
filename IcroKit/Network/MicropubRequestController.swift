//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import Alamofire
import Settings
import Client

final class MicropubRequestController {
    private var currentlyRunningTask: Request?

    private let client: Client

    init(client: Client = URLSession.shared) {
        self.client = client
    }

    func post(token: String, message: String, destination: URL?, categories: [String], draft: Bool) async throws {
        let request = Self.postRequest(token: token,
                                       message: message,
                                       destination: destination,
                                       categories: categories,
                                       draft: draft)
        let (_, response) = try await client.data(for: request, delegate: nil)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw NetworkingError.httpStatus(response.statusCode)
        }
    }

    static func postRequest(token: String,
                            message: String,
                            destination: URL?,
                            categories: [String],
                            draft: Bool) -> URLRequest {
        var request = URLRequest(url: MicropubEndpoint.url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "h", value: "entry"),
                                 URLQueryItem(name: "content", value: message)]
        if let destination {
            components.queryItems?.append(URLQueryItem(name: "mp-destination", value: destination.absoluteString))
        }
        for category in categories {
            components.queryItems?.append(URLQueryItem(name: "category[]", value: category))
        }
        if draft {
            components.queryItems?.append(URLQueryItem(name: "post-status", value: "draft"))
        }
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        return request
    }

    func cancelImageUpload() {
        currentlyRunningTask?.cancel()
    }

    func uploadImages(token: String,
                      destination: URL?,
                      image: XImage,
                      uploadProgress: @escaping (Float) -> Void,
                      completion: @escaping (ComposeViewModel.Image?, Error?) -> Void) {

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        client.load(resource: MediaEndpoint.get(token: token)) { endpoint in
            let endpointValue = endpoint.value?.mediaEndpoint

            guard let url = endpointValue, let jpeg = image.jpeg else {
                completion(nil, NetworkingError.cannotParse)
                return
            }

            let filename = UUID().uuidString + ".jpg"
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(jpeg, withName: "file", fileName: filename, mimeType: "image/jpeg")
                if let destination {
                    multipartFormData.append(Data(destination.absoluteString.utf8), withName: "mp-destination")
                }
            },
                             usingThreshold: UInt64.init(),
                             to: url,
                             method: .post,
                             headers: headers,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    self.currentlyRunningTask = upload.responseJSON(completionHandler: { response in
                                        if let linkURLString = response.response?.allHeaderFields["Location"] as? String,
                                            let url = URL(string: linkURLString) {
                                            completion(ComposeViewModel.Image(title: filename, link: url), nil)
                                            return
                                        }
                                        completion(nil, NetworkingError.cannotParse)
                                    })

                                    upload.uploadProgress { progress in
                                        uploadProgress(Float(progress.fractionCompleted))
                                    }
                                case .failure(let encodingError):
                                    completion(nil, encodingError)
                                }
            })
        }
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary: URLQueryParameterStringConvertible {
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).stringByAddingPercentEncodingForFormData() ?? "",
                              String(describing: value).stringByAddingPercentEncodingForFormData() ?? "")
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}

extension URL {
    func appendingQueryParameters(_ parametersDictionary: [String: String]) -> URL {
        let URLString: String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}

extension XImage {
    var jpeg: Data? {
        #if os(OSX)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
        #elseif os(iOS)
        return self.jpegData(compressionQuality: 1)   // QUALITY min = 0 / max = 1
        #endif
    }
}
