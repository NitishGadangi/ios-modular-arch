import Foundation
import Combine
import DetailsInterface
import NetworkLib

final class DetailsRepository: DetailsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProductDetail(id: String) -> AnyPublisher<ProductDetail, Error> {
        let endpoint = FakeStoreAPI.product(id: Int(id) ?? 0)
        return networkService.request(endpoint, responseType: ProductDetail.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
