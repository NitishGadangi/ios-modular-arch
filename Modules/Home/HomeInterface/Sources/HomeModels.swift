import Foundation

public struct ProductSummary: Equatable, Decodable, Identifiable {
    public let id: String
    public let name: String
    public let price: Double
    public let imageUrl: String
    public let description: String

    public init(id: String, name: String, price: Double, imageUrl: String, description: String) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.description = description
    }
}
