//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import Alamofire

class MicropubRequestController {
    enum Endpoint {
        case micropub
        case custom(info: UserSettings.MicropubInfo)

        var urlString: String {
            switch self {
            case .micropub:
                return "https://micro.blog/micropub"
            case .custom(let info):
                return info.urlString
            }
        }

        var token: String {
            switch self {
            case .micropub:
                return UserSettings.shared.token
            case .custom(let info):
                return info.micropubToken
            }
        }
    }

    private var currentlyRunningTask: Request?

    func post(endpoint: Endpoint, message: String, completion: @escaping (Error?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default

        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let URL = URL(string: endpoint.urlString) else {
            completion(NetworkingError.micropubURLError)
            return
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

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (_, _, error: Error?) -> Void in
            DispatchQueue.main.async {
                if error == nil {
                    completion(nil)
                } else {
                    completion(NetworkingError.micropubURLError)
                }
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    func cancelImageUpload() {
        currentlyRunningTask?.cancel()
    }

    func uploadImages(image: UIImage,
                      uploadProgress: @escaping (Float) -> Void,
                      completion: @escaping (ComposeViewModel.Image?, Error?) -> Void) {

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserSettings.shared.token)"
        ]

        Webservice().load(resource: MediaEndpoint.get(), bearer: true) { endpoint in
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

extension String {
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: unreserved)

        if plusForSpace {
            allowedCharacterSet.addCharacters(in: " ")
        }

        var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
        if plusForSpace {
            encoded = encoded?.replacingOccurrences(of: " ", with: "+")
        }
        return encoded
    }
}

extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 1)   // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}

struct MediaEndpoint: Codable {
    let mediaEndpoint: URL
}

extension MediaEndpoint {
    init?(dictionary: JSONDictionary) {
        guard let endpointString = dictionary["media-endpoint"] as? String,
        let url = URL(string: endpointString) else { return nil }
        self.mediaEndpoint = url
    }
}
