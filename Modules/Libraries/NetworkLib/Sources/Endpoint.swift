import Foundation

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?

    public init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }

    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}
