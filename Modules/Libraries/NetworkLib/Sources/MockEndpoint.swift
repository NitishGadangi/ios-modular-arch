import Foundation

public enum MockEndpoint: Endpoint {
    case products
    case productDetail(id: String)

    public var baseURL: String { "" }

    public var path: String {
        switch self {
        case .products:
            return "/products"
        case .productDetail(let id):
            return "/products/\(id)"
        }
    }

    public var method: HTTPMethod { .get }

    public var queryParams: [String: String]? { nil }
}
