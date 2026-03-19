import Foundation
import Combine
import HomeInterface
import NetworkLib

final class HomeRepository: HomeRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProducts() -> AnyPublisher<[ProductSummary], Error> {
        let endpoint = FakeStoreAPI.products
        return networkService.request(endpoint, responseType: [ProductSummary].self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
