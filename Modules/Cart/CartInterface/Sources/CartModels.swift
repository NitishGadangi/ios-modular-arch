import Foundation

public struct CartItem: Equatable, Decodable, Identifiable {
    public let productId: String
    public let name: String
    public let price: Double
    public var quantity: Int

    public var id: String { productId }

    public init(productId: String, name: String, price: Double, quantity: Int) {
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

public struct CartResponse: Decodable {
    public let items: [CartItem]
    public let total: Double
}
