import Foundation
import Combine
import HomeInterface
import AnalyticsLib

final class HomeViewModel {
    enum NavigationEvent {
        case productSelected(id: String)
        case cartTapped
    }

    let navigation = PassthroughSubject<NavigationEvent, Never>()
    @Published private(set) var products: [ProductSummary] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let getProductsUseCase: GetProductsUseCase
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(getProductsUseCase: GetProductsUseCase, analytics: AnalyticsServiceProtocol) {
        self.getProductsUseCase = getProductsUseCase
        self.analytics = analytics
    }

    func loadProducts() {
        isLoading = true
        errorMessage = nil

        getProductsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] products in
                    self?.products = products
                    self?.analytics.track(AnalyticsEvent(
                        name: "products_loaded",
                        parameters: ["count": "\(products.count)"]
                    ))
                }
            )
            .store(in: &cancellables)
    }

    func didSelectProduct(id: String) {
        analytics.track(AnalyticsEvent(name: "product_tapped", parameters: ["product_id": id]))
        navigation.send(.productSelected(id: id))
    }

    func didTapCart() {
        navigation.send(.cartTapped)
    }
}
