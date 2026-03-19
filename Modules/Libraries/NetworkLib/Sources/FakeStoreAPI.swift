import Foundation

public enum FakeStoreAPI: Endpoint {
    case products
    case product(id: Int)

    public var baseURL: String { "" }

    public var path: String {
        switch self {
        case .products:
            return "/products"
        case .product(let id):
            return "/products/\(id)"
        }
    }

    public var method: HTTPMethod { .get }

    public var queryParams: [String: String]? { nil }
}
