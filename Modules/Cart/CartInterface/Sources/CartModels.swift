import Foundation

public struct CartItem: Equatable, Decodable, Identifiable {
    public let productId: String
    public let name: String
    public let price: Double
    public var quantity: Int
    public let imageURL: String

    public var id: String { productId }

    public init(productId: String, name: String, price: Double, quantity: Int, imageURL: String = "") {
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.imageURL = imageURL
    }
}
