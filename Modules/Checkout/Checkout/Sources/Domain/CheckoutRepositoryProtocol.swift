import Foundation
import Combine
import CheckoutInterface

protocol CheckoutRepositoryProtocol {
    func placeOrder(total: Double) -> AnyPublisher<OrderSummary, Error>
}
