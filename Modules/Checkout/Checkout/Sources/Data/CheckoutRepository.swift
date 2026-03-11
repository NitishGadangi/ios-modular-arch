import Foundation
import Combine
import CheckoutInterface
import NetworkLib

final class CheckoutRepository: CheckoutRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func placeOrder(total: Double) -> AnyPublisher<OrderSummary, Error> {
        let endpoint = Endpoint(path: "/checkout", method: .post)
        return networkService.request(endpoint, responseType: OrderSummary.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
