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

    func post(endpoint: MicropubEndpoint, message: String) async throws {
        let sessionConfig = URLSessionConfiguration.default

        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let URL = URL(string: endpoint.urlString) else {
            throw NetworkingError.micropubURLError
        }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        request.addValue("Bearer \(endpoint.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "name": "",
            "content": message,
            "h": "entry"
            ]
        let bodyString = bodyParameters.queryParameters
        request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)

        try await _ = session.data(for: request, delegate: nil)

        session.finishTasksAndInvalidate()
    }

    func cancelImageUpload() {
        currentlyRunningTask?.cancel()
    }

    func uploadImages(endpoint: MicropubEndpoint,
                      image: XImage,
                      uploadProgress: @escaping (Float) -> Void,
                      completion: @escaping (ComposeViewModel.Image?, Error?) -> Void) {

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(endpoint.token)"
        ]

        client.load(resource: MediaEndpoint.get(endpoint: endpoint)) { endpoint in
            let endpointValue = endpoint.value?.mediaEndpoint

            guard let url = endpointValue else { return }

            let filename = UUID().uuidString + ".jpg"
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(image.jpeg!, withName: "file", fileName: filename, mimeType: "image/jpeg")
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
                                        }
                                        completion(nil, nil)
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
