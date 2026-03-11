import Foundation
import Combine
import HomeInterface

protocol HomeRepositoryProtocol {
    func fetchProducts() -> AnyPublisher<[ProductSummary], Error>
}
