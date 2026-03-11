import Foundation
import Combine

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}
