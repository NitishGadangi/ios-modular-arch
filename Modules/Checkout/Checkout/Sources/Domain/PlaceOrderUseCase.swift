import Foundation
import Combine
import CheckoutInterface

final class PlaceOrderUseCase {
    private let repository: CheckoutRepositoryProtocol

    init(repository: CheckoutRepositoryProtocol) {
        self.repository = repository
    }

    func execute(total: Double) -> AnyPublisher<OrderSummary, Error> {
        repository.placeOrder(total: total)
    }
}
