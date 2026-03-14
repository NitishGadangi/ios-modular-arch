import Foundation
import Combine

public protocol NetworkServiceProtocol {
    func configure(with configuration: NetworkConfiguration)
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}
