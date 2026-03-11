import Foundation
import Combine
import CartInterface

final class CartRepository: CartRepositoryProtocol {
    private let cartService: CartServiceProtocol

    init(cartService: CartServiceProtocol) {
        self.cartService = cartService
    }

    func fetchCart() -> AnyPublisher<[CartItem], Never> {
        cartService.items.eraseToAnyPublisher()
    }
}
