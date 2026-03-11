import Foundation
import Combine

public final class MockNetworkService: NetworkServiceProtocol {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    public init(bundle: Bundle? = nil) {
        self.bundle = bundle ?? .module
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        let fileName = mapEndpointToFile(endpoint)

        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: NetworkError.noData).eraseToAnyPublisher()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try decoder.decode(T.self, from: data)
            return Just(decoded)
                .setFailureType(to: NetworkError.self)
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.decodingFailed(error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }

    private func mapEndpointToFile(_ endpoint: Endpoint) -> String {
        switch endpoint.path {
        case "/products":
            return "products"
        case let path where path.hasPrefix("/products/"):
            return "product_detail"
        case "/cart":
            return "cart"
        case "/checkout":
            return "checkout_response"
        default:
            return endpoint.path.replacingOccurrences(of: "/", with: "_")
        }
    }
}
