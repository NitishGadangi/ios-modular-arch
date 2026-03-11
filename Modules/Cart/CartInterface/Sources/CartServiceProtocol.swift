import Foundation
import Combine

public protocol CartServiceProtocol: AnyObject {
    var items: CurrentValueSubject<[CartItem], Never> { get }
    var totalPrice: Double { get }
    func addItem(_ item: CartItem)
    func removeItem(productId: String)
    func updateQuantity(productId: String, quantity: Int)
    func clearCart()
}
