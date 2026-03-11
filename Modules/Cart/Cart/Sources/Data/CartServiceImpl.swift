import Foundation
import Combine
import CartInterface

public final class CartServiceImpl: CartServiceProtocol {
    public let items = CurrentValueSubject<[CartItem], Never>([])
    private let lock = NSLock()

    public var totalPrice: Double {
        lock.lock()
        defer { lock.unlock() }
        return items.value.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    public init() {}

    public func addItem(_ item: CartItem) {
        lock.lock()
        defer { lock.unlock() }
        var current = items.value
        if let index = current.firstIndex(where: { $0.productId == item.productId }) {
            var existing = current[index]
            existing = CartItem(
                productId: existing.productId,
                name: existing.name,
                price: existing.price,
                quantity: existing.quantity + item.quantity
            )
            current[index] = existing
        } else {
            current.append(item)
        }
        items.send(current)
    }

    public func removeItem(productId: String) {
        lock.lock()
        defer { lock.unlock() }
        var current = items.value
        current.removeAll { $0.productId == productId }
        items.send(current)
    }

    public func updateQuantity(productId: String, quantity: Int) {
        lock.lock()
        defer { lock.unlock() }
        var current = items.value
        if let index = current.firstIndex(where: { $0.productId == productId }) {
            if quantity <= 0 {
                current.remove(at: index)
            } else {
                let existing = current[index]
                current[index] = CartItem(
                    productId: existing.productId,
                    name: existing.name,
                    price: existing.price,
                    quantity: quantity
                )
            }
        }
        items.send(current)
    }

    public func clearCart() {
        lock.lock()
        defer { lock.unlock() }
        items.send([])
    }
}
