import Foundation

public struct ProductDetail: Equatable, Decodable, Identifiable {
    public let id: Int
    public let title: String
    public let price: Double
    public let description: String
    public let category: String
    public let image: String
    public let rating: Rating

    public struct Rating: Equatable, Decodable {
        public let rate: Double
        public let count: Int

        public init(rate: Double, count: Int) {
            self.rate = rate
            self.count = count
        }
    }

    public init(id: Int, title: String, price: Double, description: String, category: String, image: String, rating: Rating) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.image = image
        self.rating = rating
    }
}
