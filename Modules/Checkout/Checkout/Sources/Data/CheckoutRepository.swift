import Foundation
import Combine
import CheckoutInterface

final class CheckoutRepository: CheckoutRepositoryProtocol {
    func placeOrder(total: Double) -> AnyPublisher<OrderSummary, Error> {
        let summary = OrderSummary(
            orderId: "ORD-\(UUID().uuidString.prefix(8))",
            status: "confirmed",
            total: total,
            estimatedDelivery: "3-5 business days"
        )
        return Just(summary)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
