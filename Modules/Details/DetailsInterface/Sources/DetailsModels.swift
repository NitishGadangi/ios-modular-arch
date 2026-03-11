import Foundation

public struct ProductDetail: Equatable, Decodable {
    public let id: String
    public let name: String
    public let price: Double
    public let imageUrl: String
    public let description: String
    public let specs: [String]
    public let rating: Double
    public let reviewCount: Int

    public init(id: String, name: String, price: Double, imageUrl: String, description: String, specs: [String], rating: Double, reviewCount: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.description = description
        self.specs = specs
        self.rating = rating
        self.reviewCount = reviewCount
    }
}
