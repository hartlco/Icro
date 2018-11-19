//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: Any]

let itemURL = URL(string: "https://micro.blog/posts/all")!
let photosURL = URL(string: "https://micro.blog/posts/photos")!
let mentionsURL = URL(string: "https://micro.blog/posts/mentions")!
let favoritesURL = URL(string: "https://micro.blog/posts/favorites")!
let discoverURL = URL(string: "https://micro.blog/posts/discover")!
let conversationsURLString = "https://micro.blog/posts/conversation?id="
let userPostsURL = URL(string: "https://micro.blog/posts/")!
let faveURLString = "https://micro.blog/posts/favorites?id="
let unfaveURLString = "https://micro.blog/posts/favorites/"
let replyURLString = "https://micro.blog/posts/reply"
let followURLString = "https://micro.blog/users/follow?username="
let unfollowURLString = "https://micro.blog/users/unfollow?username="
let followingURLString = "http://micro.blog/users/following/"

public let microblogMedia = "?q=config"

public struct Resource<A> {
    let url: URL
    let httpMethod: String
    let parse: (Data) -> Result<A>
}

public enum NetworkingError: Error {
    case cannotParse
    case wordPressURLError
    case micropubURLError
    case generalError(error: Error)
    case invalidInput
}

public enum Result<A> {
    case error(error: Error)
    case result(value: A)

    public var value: A? {
        switch self {
        case .error:
            return nil
        case .result(let value):
            return value
        }
    }

    public init(value: A?, error: Error) {
        if let value = value {
            self = .result(value: value)
        } else {
            self = .error(error: error)
        }
    }
}

public extension Resource {
    init(url: URL, httpMethod: String = "GET", parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])

            return Result(value: json.flatMap(parseJSON), error: NetworkingError.cannotParse)
        }
        self.httpMethod = httpMethod
    }
}

public extension Item {
    static func allCached(completion: @escaping (ItemResponse?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let response = CacheStorage.retrieve("homestream", from: CacheStorage.Directory.caches, as: ItemResponse.self)
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }

    static func deleteAllCached() {
        CacheStorage.remove("homestream", from: .caches)
    }

    static func saveAllCached(itemResponse: ItemResponse) {
        var response = itemResponse
        if response.items.count > 400 {
            response = ItemResponse(author: response.author, items: Array(response.items[..<400]))

        }

        CacheStorage.store(response, to: CacheStorage.Directory.caches, as: "homestream")
    }

    static func all() -> Resource<ItemResponse> {
        if let itemResponse = CacheStorage.retrieve("homestream",
                                                    from: CacheStorage.Directory.caches,
                                                    as: ItemResponse.self),
            itemResponse.items.count > 0 {
            return allSince(items: itemResponse.items)
        }

        return allItems
    }

    private static let allItems = resource(for: itemURL, cacheName: "homestream")

    private static func allSince(items: [Item]) -> Resource<ItemResponse> {
        let url = itemURL

        return Resource<ItemResponse>(url: url, parseJSON: { json in
            guard let jsonDictionary = json as? JSONDictionary,
                let jsonItems = jsonDictionary["items"] as? [JSONDictionary] else {
                    return nil
            }

            let newItems = jsonItems.compactMap(Item.init)
            // Only add new items to the array
            let allItemsSet = Set<Item>(newItems + items)
            let allItems = Array(allItemsSet).sorted(by: {
                return ($0.date_published >= $1.date_published)
            })
            let response = ItemResponse(author: nil, items: filtered(items: allItems))
            Item.saveAllCached(itemResponse: response)
            return response
        })
    }

    static let mentions = resource(for: mentionsURL)

    static func resourceBefore(oldResource: Resource<ItemResponse>, item: Item) -> Resource<ItemResponse> {
        let url = urlWithBeforeParameter(url: oldResource.url, item: item)
        return resource(for: url)

    }

    private static func urlWithBeforeParameter(url: URL, item: Item) -> URL {
        return url.appendingQueryParameters(["before_id": item.id])
    }

    static let favorites = resource(for: favoritesURL)

    static let discover = resource(for: discoverURL)

    static func discoverCollection(for category: DiscoveryCategory) -> Resource<ItemResponse> {
        let url = discoverURL.appendingPathComponent(category.category)
        return resource(for: url)
    }

    static let photos = resource(for: photosURL)

    static func usernamePostURL(for username: String) -> Resource<ItemResponse> {
        let url = userPostsURL.appendingPathComponent(username)
        return Resource<ItemResponse>(url: url, parseJSON: { json in
            guard let jsonDictionary = json as? JSONDictionary,
                let jsonItems = jsonDictionary["items"] as? [JSONDictionary],
                let microBlogJson = jsonDictionary["_microblog"] as? JSONDictionary,
                let authorJson = jsonDictionary["author"] as? JSONDictionary,
                let author = Author(dictionary: authorJson, microBlog: microBlogJson) else {
                    return nil
            }

            let items = filtered(items: jsonItems.compactMap(Item.init))
            return ItemResponse(author: author, items: items)
        })
    }

    fileprivate static func resource(for url: URL, cacheName: String? = nil) -> Resource<ItemResponse> {
        return Resource<ItemResponse>(url: url, parseJSON: { json in
            guard let jsonDictionary = json as? JSONDictionary,
                let jsonItems = jsonDictionary["items"] as? [JSONDictionary] else {
                    return nil
            }

            let response = ItemResponse(author: nil, items: filtered(items: jsonItems.compactMap(Item.init)))

            if let cacheName = cacheName {
                CacheStorage.store(response, to: CacheStorage.Directory.caches, as: cacheName)
            }

            return response
        })
    }

    static func resource(forAuthor author: Author) -> Resource<ItemResponse> {
        return usernamePostURL(for: author.username ?? "")
    }

    static func filtered(items: [Item]) -> [Item] {
        let blacklist = UserSettings.shared.blacklist

        return items.filter({ item in
            let username = item.author.username ?? ""
            let name = item.author.name

            let all = username + " " + name + " " + item.content.string
            for word in blacklist {
                if all.contains(word) {
                    return false
                }
            }

            return true
        })
    }

    func toggleFave() -> Resource<Empty> {
        let httpMethod = isFavorite ? "DELETE" : "POST"

        let baseUrl = isFavorite ? unfaveURLString : faveURLString
        let urlString = baseUrl + id
        let url = URL(string: urlString)!
        return Resource<Empty>(url: url, httpMethod: httpMethod, parseJSON: { _ in return Empty() })
    }

    func reply(with text: String) -> Resource<Empty> {
        let encodedText = text.stringByAddingPercentEncodingForFormData() ?? ""
        let url = URL(string: replyURLString + "?id=\(id)&text=\(encodedText)")!
        return Resource<Empty>(url: url, httpMethod: "POST", parseJSON: { _ in return Empty() })
    }

    var conversation: Resource<ItemResponse> {
        let urlString = conversationsURLString + id
        let url = URL(string: urlString)!

        return Item.resource(for: url)
    }

    static func post(text: String) -> Resource<Empty> {
        let content = text.stringByAddingPercentEncodingForFormData() ?? ""

        let urlString = "https://" + UserSettings.shared.defaultSite + "/micropub?h=entry&content=\(content)"
        let url = URL(string: urlString)!
        return Resource<Empty>(url: url, httpMethod: "POST", parseJSON: { _ in
            return Empty()
        })
    }
}

public extension Author {
    func followResource() -> Resource<Empty> {
        guard let username = username else {
            fatalError()
        }
        let url = URL(string: followURLString + username)!
        return Resource<Empty>(url: url, httpMethod: "POST", parseJSON: { _ in
            return Empty()
        })
    }

    func unfollowResource() -> Resource<Empty> {
        guard let username = username else {
            fatalError()
        }
        let url = URL(string: unfollowURLString + username)!
        return Resource<Empty>(url: url, httpMethod: "POST", parseJSON: { _ in
            return Empty()
        })
    }

    func followingResource() -> Resource<[Author]> {
        guard let username = username else {
            fatalError()
        }
        let url = URL(string: followingURLString + username)!
        return Resource<[Author]>(url: url, httpMethod: "GET", parseJSON: { json in
            guard let jsonItems = json as? [JSONDictionary] else {
                    return nil
            }

            return jsonItems.compactMap(Author.init(dictionary:))
        })
    }
}

public struct MediaEndpoint: Codable {
    public let mediaEndpoint: URL
}

extension MediaEndpoint {
    init?(dictionary: JSONDictionary) {
        guard let endpointString = dictionary["media-endpoint"] as? String,
            let url = URL(string: endpointString) else { return nil }
        self.mediaEndpoint = url
    }
}

public extension MediaEndpoint {
    public static func get(endpoint: MicropubEndpoint) -> Resource<MediaEndpoint> {
        let urlString = endpoint.urlString + microblogMedia

        guard let url = URL(string: urlString) else {
            fatalError()
        }

        return Resource<MediaEndpoint>(url: url, parseJSON: { json in
            guard let json = json as? JSONDictionary else {
                return nil
            }

            return MediaEndpoint(dictionary: json)
        })
    }
}

public final class Webservice {
    public init() { }

    public func load<A: Codable>(resource: Resource<A>, bearer: Bool = false, completion: @escaping (Result<A>) -> Void) {
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.httpMethod
        if bearer {
            request.addValue("Bearer \(UserSettings.shared.token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue(UserSettings.shared.token, forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(.error(error: NetworkingError.cannotParse))
                    return
                }
                let finalData = resource.parse(data)
                completion(finalData)
            }
        }.resume()
    }
}

extension URLComponents {
    init(scheme: String, host: String, path: String, queryItems: [URLQueryItem]) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
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
