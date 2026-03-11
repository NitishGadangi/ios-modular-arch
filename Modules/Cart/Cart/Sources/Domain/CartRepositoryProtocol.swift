import Foundation
import Combine
import CartInterface

protocol CartRepositoryProtocol {
    func fetchCart() -> AnyPublisher<[CartItem], Never>
}
