//
//  IndieAuth.swift
//  IndieAuth
//
//  Created by Eddie Hinkle on 4/29/17.
//  Copyright © 2017 Studio H, LLC. All rights reserved.
//

import Foundation

// Adapted from https://github.com/EdwardHinkle/indigenous-ios
public class IndieAuth {
    public struct Constants {
        public static let tokenURL = URL(string: "https://tokens.indieauth.com/token")!
        public static let authURL = URL(string: "https://indieauth.com/auth")!
        public static let callback = URL(string: "icro://auth")!
        public static let clientIDURL = URL(string: "https://hartl.co/apps/icro")!
    }
    // Input: Any URL or string like "eddiehinkle.com"
    // Output: Normlized URL (default to http if no scheme, default "/" path)
    //         or return false if not a valid URL (has query string params, etc)
    public static func normalizeMeURL(url: String) -> URL? {

        var meUrl = URLComponents(string: url)

        // If there is no scheme or host, the host is probably in the path
        if meUrl?.scheme == nil && meUrl?.host == nil {
            // If the path is nil or empty, then our url is probably empty. Mayday!
            if meUrl?.path == nil || meUrl?.path == "" {
                return nil
            }

            // Split the path into segments so we can seperate the host and the path
            print("Running normalize url")
            let pathSegments = meUrl?.path.components(separatedBy: "/")

            meUrl?.host = pathSegments?.first
            meUrl?.path = "/" + (pathSegments?.dropFirst().joined() ?? "")
        }

        // If no scheme, we default to http
        if meUrl?.scheme == nil {
            meUrl?.scheme = "http"
        } else if meUrl?.scheme != "http" && meUrl?.scheme != "https" {
            // If there is a scheme, we only accept http and https schemes
            print("Scheme existed and wasn't http or https: \(meUrl?.scheme ?? "No Scheme")")
            return nil
        }

        // We default to a path of /
        if meUrl?.path == nil || meUrl?.path == "" {
            meUrl?.path = "/"
        }

        meUrl?.fragment = nil
        meUrl?.query = nil

        return meUrl?.url
    }

    public static func buildAuthorizationURL(forEndpoint authorizationEndpoint: URL,
                                             meUrl: URL,
                                             redirectURI: URL,
                                             clientId: URL,
                                             state: String,
                                             scope: String = "") -> URL? {

        var authorizationUrl = URLComponents(url: authorizationEndpoint.absoluteURL, resolvingAgainstBaseURL: false)

        var authorizationDetails: [URLQueryItem] = []
        authorizationDetails.append(URLQueryItem(name: "me", value: meUrl.absoluteString))
        authorizationDetails.append(URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString))
        authorizationDetails.append(URLQueryItem(name: "client_id", value: clientId.absoluteString))
        authorizationDetails.append(URLQueryItem(name: "state", value: state))
        authorizationDetails.append(URLQueryItem(name: "scope", value: scope))
        authorizationDetails.append(URLQueryItem(name: "response_type", value: "code"))
        authorizationUrl?.queryItems = authorizationDetails

        return authorizationUrl?.url
    }

    // swiftlint:disable function_parameter_count
    public static func makeTokenRequest(forEndpoint tokenEndpoint: URL,
                                        meUrl: URL,
                                        code: String,
                                        redirectURI: URL,
                                        clientId: String,
                                        state: String? = nil,
                                        completion: @escaping (URL, String, String) -> Void) {

            var request = URLRequest(url: tokenEndpoint)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var bodyString = "grant_type=authorization_code&me=" +
                meUrl.absoluteString +
                "&code=" +
                code +
                "&redirect_uri=" +
                redirectURI.absoluteString +
                "&client_id=" +
        clientId

            if state != nil {
                bodyString += "&state=" + state!
            }

            let bodyData = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            request.httpBody = bodyData

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)

            let task = session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    return
                }

                // Check if endpoint is in the HTTP Header fields
                if let httpResponse = response as? HTTPURLResponse, let body = String(data: data!, encoding: .utf8) {
                    if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                        if httpResponse.statusCode == 200 {
                            if contentType.contains("application/json") {
                                if let tokenResponse = try? JSONDecoder().decode(IndieAuthTokenResponse.self,
                                                                                 from: body.data(using: .utf8)!) {
                                    completion(tokenResponse.me, tokenResponse.scope, tokenResponse.access_token)
                                }

                            } else if contentType.contains("application/x-www-form-urlencoded") {
                                // todo: Check body for "error=" string.
                                // todo: Verify meUrl and returnedUrl match domains
                                let bodyComponents = IndieAuth.convertForm(body: body)
                                if let accessToken = bodyComponents["access_token"],
                                    let scope = bodyComponents["scope"],
                                    let returnedMeUrl = URL(string: bodyComponents["me"]!) {
                                    completion(returnedMeUrl, scope, accessToken)
                                }

                            }
                        }
                    }
                }

            }

            task.resume()

    }

    private static func convertForm(body: String) -> [String: String] {
        var bodyDictionary: [String: String] = [:]

        // Look through form body items
        for item in body.components(separatedBy: "&") {
            // Split item into name and value
            let itemComponents = item.components(separatedBy: "=")
            // Assign item value to item name in dictionary
            bodyDictionary[itemComponents[0]] = itemComponents[1]
        }

        return bodyDictionary
    }
}

public struct IndieAuthTokenResponse: Codable {
    let access_token: String
    let scope: String
    let me: URL
}
