import Foundation
import Combine
import DetailsInterface

final class GetProductDetailUseCase {
    private let repository: DetailsRepositoryProtocol

    init(repository: DetailsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(productId: String) -> AnyPublisher<ProductDetail, Error> {
        repository.fetchProductDetail(id: productId)
    }
}
