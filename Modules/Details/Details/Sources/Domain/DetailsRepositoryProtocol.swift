import Foundation
import Combine
import DetailsInterface

protocol DetailsRepositoryProtocol {
    func fetchProductDetail(id: String) -> AnyPublisher<ProductDetail, Error>
}
