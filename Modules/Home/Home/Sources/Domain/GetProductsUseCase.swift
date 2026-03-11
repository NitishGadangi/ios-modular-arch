import Foundation
import Combine
import HomeInterface

final class GetProductsUseCase {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[ProductSummary], Error> {
        repository.fetchProducts()
    }
}
